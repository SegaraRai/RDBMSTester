import { createConnection } from "mariadb";
import pg from "pg";
import sqlite3 from "sqlite3";
import type { Engine } from "./engines.mjs";

export type RDBMS = {
  engine: Engine;
  clear: () => Promise<void>;
  transaction: (
    callback: (query: (sql: string) => Promise<unknown[]>) => Promise<void>
  ) => void;
  exec: (sql: string) => Promise<void>;
  query: (sql: string) => Promise<unknown[]>;
  dispose?: () => Promise<void>;
};

function splitStatements(sql: string): string[] {
  return sql
    .split(/;[ \t]*\r?\n/)
    .filter((statement) => /\S/.test(statement))
    .map((statement) => `${statement};`);
}

export async function createSQLite3(): Promise<RDBMS> {
  const db = new sqlite3.Database(":memory:");

  const exec = (sql: string) =>
    new Promise<void>((resolve, reject) => {
      db.exec(sql, (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });

  const query = (sql: string) =>
    new Promise<unknown[]>((resolve, reject) => {
      db.all(sql, (err, rows) => {
        if (err) {
          reject(err);
        } else {
          resolve(rows);
        }
      });
    });

  await exec("PRAGMA foreign_keys = ON;");

  return {
    engine: "SQLite",
    clear: async () => {
      await exec(`
        PRAGMA foreign_keys = OFF;
        PRAGMA writable_schema = 1;
        DELETE FROM sqlite_master;
        PRAGMA writable_schema = 0;
        VACUUM;
        PRAGMA integrity_check;
        PRAGMA foreign_keys = ON;
      `);
    },
    transaction: async (callback) => {
      await exec("BEGIN TRANSACTION;");
      try {
        const result = await callback(query);
        await exec("COMMIT;");
        return result;
      } catch (e) {
        await exec("ROLLBACK;");
        throw e;
      }
    },
    exec,
    query,
    dispose: () =>
      new Promise((resolve, reject) =>
        db.close((err) => (err ? reject(err) : resolve()))
      ),
  };
}

export async function createMariaDB(url: string): Promise<RDBMS> {
  let conn = await createConnection(url);

  return {
    engine: "MariaDB",
    clear: async () => {
      const tables = await conn.query(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = DATABASE();"
      );
      await conn.execute("SET FOREIGN_KEY_CHECKS = OFF;");
      for (const { table_name } of tables) {
        await conn.execute(`DROP TABLE \`${table_name}\`;`);
      }
      await conn.execute("SET FOREIGN_KEY_CHECKS = ON;");
    },
    transaction: async (callback) => {
      await conn.beginTransaction();
      try {
        const result = await callback((sql) => conn.query(sql));
        await conn.commit();
        return result;
      } catch (e) {
        await conn.rollback();
        throw e;
      }
    },
    exec: async (sql) => {
      for (const stmt of splitStatements(sql)) {
        await conn.execute(stmt);
      }
    },
    query: async (sql) => {
      let result;
      for (const stmt of splitStatements(sql)) {
        result = await conn.query(stmt);
      }
      return result;
    },
    dispose: async () => {
      await conn.end();
    },
  };
}

export async function createPostgreSQL(url: string): Promise<RDBMS> {
  const client = new pg.Client(url);

  await client.connect();

  const query = async (sql: string) => {
    const ret = await client.query(sql);
    return ret.rows;
  };

  return {
    engine: "PostgreSQL",
    clear: async () => {
      await query(`
        DROP SCHEMA public CASCADE;
        CREATE SCHEMA public;
        GRANT ALL ON SCHEMA public TO postgres;
        GRANT ALL ON SCHEMA public TO public;
      `);
    },
    transaction: async (callback) => {
      await client.query("BEGIN TRANSACTION;");
      try {
        const result = await callback(query);
        await client.query("COMMIT;");
        return result;
      } catch (e) {
        await client.query("ROLLBACK;");
        throw e;
      }
    },
    exec: async (sql) => {
      await client.query(sql);
    },
    query,
    dispose: async () => {
      await client.end();
    },
  };
}
