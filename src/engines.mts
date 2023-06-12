export const ENGINES = ["MariaDB", "PostgreSQL", "SQLite"] as const;
export type Engine = (typeof ENGINES)[number];
