import { ENGINES, type Engine } from "./engines.mjs";

export type Expected = "success" | "error" | (string | number | boolean)[];

export interface TestCase {
  name: string;
  sql: string;
  expected: Expected;
}

export interface Test {
  name: string;
  engine: Engine;
  setupSQL: string;
  cases: TestCase[];
}

interface Directive {
  name: string;
  condition: string | null;
  args: string[];
}

function unescapeArg(str: string) {
  if (str.startsWith('"') && str.endsWith('"')) {
    return JSON.parse(str);
  }
  return str.replace(/\\./g, (c) => (c[1] === "\\" || c[1] === " " ? c[1] : c));
}

function parseDirective(directive: string): Directive | null {
  const match = directive
    .trim()
    .match(/^---\s+@(\S+)(?:\s+\(([^)]*)\))?(?:\s+(.*))?$/);
  if (!match) {
    return null;
  }

  const [, name, condition, strArgs] = match;
  const args: string[] = [];
  if (name === "expected") {
    args.push(strArgs?.trim() || "");
  } else {
    let restArgs = strArgs?.trim() || "";
    while (restArgs) {
      const match = strArgs.match(/^("(?:\\.|[^\\"])*"|(?:\\ |[^ ])+) */);
      if (!match) {
        throw new Error(`Invalid directive: ${directive}`);
      }
      args.push(unescapeArg(match[1]));
      restArgs = restArgs.slice(match[0].length);
    }
  }

  return {
    name,
    condition: condition ?? null,
    args,
  };
}

function checkCondition(condition: string | null, engine: Engine) {
  if (condition === null) {
    return true;
  }

  return condition.split(/\s*\|\s*/).some((expr) => {
    const exprEngine = expr.replace(/^!/, "");
    if (!ENGINES.includes(exprEngine as Engine)) {
      throw new Error(`Unknown engine: ${exprEngine}`);
    }

    if (expr.startsWith("!")) {
      return expr.slice(1) !== engine;
    }
    return expr === engine;
  });
}

function processReplacements(
  str: string,
  replacements: readonly (readonly [string, string])[]
) {
  return replacements.reduce(
    (acc, [from, to]) => acc.replaceAll(from, to),
    str
  );
}

function parseExpected(args: readonly string[]): Expected {
  const strArgs = args.join(" ");
  if (strArgs === "success" || strArgs === "error") {
    return strArgs;
  }
  return JSON.parse(strArgs);
}

function removeDirectives(str: string): string {
  return str.replace(/^---\s+@.+$/gm, "").trim();
}

export function parseTest(
  name: string,
  testCase: string,
  engine: Engine
): Test | null {
  const [schema, ...casesSplitted] = testCase.split(/(^---\s+@test\s)/m);

  const cases = casesSplitted.reduce((acc, cur, index) => {
    if (index % 2) {
      acc[acc.length - 1] += cur;
    } else {
      acc.push(cur);
    }
    return acc;
  }, [] as string[]);

  const schemaReplacements: [string, string][] = [];
  for (const line of schema.split("\n")) {
    const directive = parseDirective(line);
    if (!directive) {
      continue;
    }

    if (!checkCondition(directive.condition, engine)) {
      if (directive.name === "schema") {
        return null;
      }
      continue;
    }

    switch (directive?.name) {
      case "replace":
        schemaReplacements.push([directive.args[0], directive.args[1]]);
        break;

      case "skip":
        return null;
    }
  }

  const setupSQL = processReplacements(
    removeDirectives(schema),
    schemaReplacements
  );
  const testCases = cases
    .map((testCase, index): TestCase | null => {
      let name = `test_${index + 1}`;
      const caseReplacements: [string, string][] = [];
      let expected: Expected = "success";
      for (const line of testCase.split("\n")) {
        const directive = parseDirective(line);
        if (!directive) {
          continue;
        }

        if (!checkCondition(directive.condition, engine)) {
          if (directive.name === "test") {
            return null;
          }
          continue;
        }

        switch (directive?.name) {
          case "test":
            name = directive.args[0];
            break;

          case "replace":
            caseReplacements.push([directive.args[0], directive.args[1]]);
            break;

          case "expect":
            expected = parseExpected(directive.args);
            break;

          case "skip":
            return null;
        }
      }

      return {
        name,
        expected,
        sql: processReplacements(removeDirectives(testCase), [
          ...schemaReplacements,
          ...caseReplacements,
        ]),
      };
    })
    .filter((testCase): testCase is TestCase => testCase !== null);

  if (!testCases.length) {
    return null;
  }

  return {
    name,
    engine,
    setupSQL,
    cases: testCases,
  };
}
