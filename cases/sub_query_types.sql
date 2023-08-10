--- @schema
CREATE TABLE tableA (id INT PRIMARY KEY, age INT);
INSERT INTO tableA (id, age) VALUES (1, 21), (2, 22), (3, 23);

--- @test sub_query_types_1
--- @expect (!SQLite) error
SELECT id, (SELECT age FROM tableA) AS age FROM tableA;

--- @test sub_query_types_2
--- @expect error
SELECT id, (SELECT * FROM tableA WHERE id = 1) AS age FROM tableA;

--- @test sub_query_types_3a
SELECT (SELECT age FROM tableA WHERE id = 1) = (SELECT age FROM tableA WHERE id = 1) AS v;

--- @test sub_query_types_3b
--- @expect (MariaDB | PostgreSQL) error
SELECT (SELECT age FROM tableA) = (SELECT age FROM tableA) AS v;

--- @test sub_query_types_3c
--- @expect (PostgreSQL) error
SELECT (SELECT id, age FROM tableA WHERE id = 1) = (SELECT id, age FROM tableA WHERE id = 1) AS v;
