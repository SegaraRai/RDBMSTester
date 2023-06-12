import { readFile } from "node:fs/promises";
import fg from "fast-glob";
import { createMariaDB, createPostgreSQL, createSQLite3 } from "./rdbms.mjs";
import { parseTest } from "./parser.mjs";
import { runTests } from "./runner.mjs";

const databases = await Promise.all([
  createSQLite3(),
  createMariaDB("mariadb://test:test@localhost:43306/test"),
  createPostgreSQL("postgresql://test:test@localhost:45432/test"),
]);
const engines = databases.map((db) => db.engine);

const caseFiles = (await fg("cases/**/*.sql")).sort();

for (const caseFile of caseFiles) {
  const filename = caseFile.split("/").pop()!.replace(/\.sql/, "");
  const content = await readFile(caseFile, "utf8");
  for (const engine of engines) {
    const parsed = parseTest(filename, content, engine);
    if (!parsed) {
      continue;
    }
    await runTests([parsed], databases);
  }
}

await Promise.all(databases.map((db) => db.dispose?.()));
