--- @schema
CREATE TABLE tableA (id INT PRIMARY KEY, age INT);
INSERT INTO tableA (id, age) VALUES (1, 21), (2, 22), (3, 23);

--- @test sub_query_as_vector_1
--- @expect [{"v":1}]
--- @expect (PostgreSQL) [{"v":true}]
SELECT (21 IN (SELECT age FROM tableA WHERE id = 1)) AS v;

--- @test sub_query_as_vector_2
--- @expect [{"v":0}]
--- @expect (PostgreSQL) [{"v":false}]
SELECT (21 IN (SELECT age FROM tableA WHERE id = 2)) AS v;

--- @test sub_query_as_vector_3
--- @expect [{"v":1}]
--- @expect (PostgreSQL) [{"v":true}]
SELECT (21 IN (SELECT age FROM tableA)) AS v;

--- @test sub_query_as_vector_4
--- @expect [{"v":1}]
--- @expect (PostgreSQL) [{"v":true}]
SELECT ((21, 1) IN (SELECT age, id FROM tableA)) AS v;
