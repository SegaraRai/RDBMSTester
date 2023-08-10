--- @schema
CREATE TABLE tableA (id INT PRIMARY KEY, age INT);
INSERT INTO tableA (id, age) VALUES (1, 21), (2, 22), (3, 23);

--- @test sub_query_as_scalar_1
SELECT id, (SELECT age FROM tableA WHERE id = 1) AS age FROM tableA;

--- @test sub_query_as_scalar_2
SELECT * FROM tableA WHERE age = (SELECT age FROM tableA WHERE id = 1);

--- @test sub_query_as_scalar_min
SELECT * FROM tableA WHERE age = (SELECT MIN(age) FROM tableA);

--- @test debug1
--- @debug
SELECT MIN(age) FROM tableA;

--- @test debug2
--- @debug
SELECT id, MIN(age) FROM tableA;

--- @test debug3
--- @debug
SELECT id, 123 FROM tableA;

--- @test debug4
--- @debug
SELECT MIN(age), 123 FROM tableA;

--- @test debug4
--- @debug
SELECT id, (SELECT MIN(age) FROM tableA) FROM tableA;

--- @test sub_query_as_scalar_single
--- @reset
DELETE FROM tableA WHERE id != 1;
SELECT * FROM tableA WHERE age = (SELECT age FROM tableA);

--- @test sub_query_as_scalar_multiple
--- @expect error
SELECT * FROM tableA WHERE age = (SELECT age FROM tableA);
