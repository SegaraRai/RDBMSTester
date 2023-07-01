import { readFile } from "node:fs/promises";
import { argv } from "node:process";
import fg from "fast-glob";
import { createMariaDB, createPostgreSQL, createSQLite3 } from "./rdbms.mjs";
import { parseTest } from "./parser.mjs";
import { runTests } from "./runner.mjs";

function filter<T extends string>(
  targets: readonly T[],
  filters: readonly string[]
): T[] {
  const filtered = targets.filter((target) =>
    filters.some((filter) => target.toLowerCase().includes(filter))
  );
  return filtered.length ? filtered : [...targets];
}

const filters = argv.slice(2).map((arg) => arg.toLowerCase());

const databases = await Promise.all([
  createSQLite3(),
  createMariaDB("mariadb://test:test@localhost:43306/test"),
  createPostgreSQL("postgresql://test:test@localhost:45432/test"),
]);
const engines = filter(
  databases.map((db) => db.engine),
  filters
);

const caseFiles = filter((await fg("cases/**/*.sql")).sort(), filters);

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
