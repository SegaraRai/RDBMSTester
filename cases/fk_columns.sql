--- @replace (!SQLite) "TEXT" "VARCHAR(255)"
--- @replace (!SQLite) "REAL" "DOUBLE PRECISION"

--- @schema
CREATE TABLE tableA (id INT PRIMARY KEY);
CREATE TABLE tableB (id INT PRIMARY KEY, ref_id INT REFERENCES tableA(id));
INSERT INTO tableA (id) VALUES (1), (2), (3);
INSERT INTO tableB (id, ref_id) VALUES (1, 1), (2, 2), (3, 3);

--- @test (!SQLite) change_datatype_larger
--- @expect (!PostgreSQL) error
--- @reset
ALTER TABLE tableA ALTER COLUMN id TYPE BIGINT;

--- @test (!SQLite) change_datatype_smaller
--- @expect (!PostgreSQL) error
--- @reset
ALTER TABLE tableA ALTER COLUMN id TYPE SMALLINT;

--- @test (!SQLite) change_datatype_smaller_overflow
--- @expect error
--- @reset
INSERT INTO tableA (id) VALUES (90000);
ALTER TABLE tableA ALTER COLUMN id TYPE SMALLINT;

--- @test change_datatype_real
--- @expect (!PostgreSQL) error
--- @reset
ALTER TABLE tableA ALTER COLUMN id TYPE REAL;

--- @test change_datatype_incompatible
--- @expect error
--- @reset
ALTER TABLE tableA ALTER COLUMN id TYPE TEXT;

--- @test remove_column
--- @expect error
--- @reset
ALTER TABLE tableA DROP COLUMN id;

--- @test rename_column
--- @reset
ALTER TABLE tableA RENAME COLUMN id TO new_id;
