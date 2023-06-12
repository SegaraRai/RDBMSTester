import { Test } from "./parser.mjs";
import { type RDBMS } from "./rdbms.mjs";

async function runTest(database: RDBMS, test: Test): Promise<void> {
  if (test.engine !== database.engine) {
    return;
  }

  await database.clear();
  await database.exec(test.setupSQL);

  for (const { name, sql, expected } of test.cases) {
    try {
      await database.transaction(async (query) => {
        let erred: boolean | Error = false;
        let result;
        try {
          result = await query(sql);
        } catch (e) {
          erred = e as Error;
        }

        const ok =
          (expected === "success" ? !erred : null) ??
          (expected === "error" ? erred : null) ??
          JSON.stringify(result) === JSON.stringify(expected);
        const actualOverride =
          expected === "success" || expected === "error"
            ? erred
              ? `error: ${erred}`
              : "success"
            : null;
        if (ok) {
          console.error(
            `Passed: ${name} on ${database.engine} (${JSON.stringify(
              expected
            )})`
          );
        } else {
          console.error(`Failed: ${name} on ${database.engine}`);
          console.error(`  SQL: ${sql}`);
          console.error(`  Expected: ${JSON.stringify(expected)}`);
          console.error(
            `  Actual: ${JSON.stringify(actualOverride || result)}`
          );
        }

        throw new Error("rollback");
      });
    } catch {}
  }
}

export async function runTests(
  tests: readonly Test[],
  databases: readonly RDBMS[]
) {
  for (const test of tests) {
    const db = databases.find((db) => db.engine === test.engine);
    if (!db) {
      continue;
    }
    console.log(`Running ${test.name} tests on ${test.engine}...`);
    await runTest(db, test);
  }
}
