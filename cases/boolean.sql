--- @schema

--- @test basic
--- @expect [{"v":1}]
--- @expect (PostgreSQL) [{"v":true}]
SELECT TRUE AS v;

--- @test comparison_result
--- @expect [{"v":1}]
--- @expect (PostgreSQL) [{"v":true}]
SELECT 1 = 1 AS v;

--- @test false_is_0
--- @expect [{"v":1}]
--- @expect (PostgreSQL) error
SELECT FALSE = 0 AS v;

--- @test true_is_1
--- @expect [{"v":1}]
--- @expect (PostgreSQL) error
SELECT TRUE = 1 AS v;

--- @test true_is_2
--- @expect [{"v":0}]
--- @expect (PostgreSQL) error
SELECT TRUE = 2 AS v;

--- @test cast_false_is_0
--- @expect [{"v":1}]
--- @expect (PostgreSQL) [{"v":true}]
SELECT CAST(FALSE AS INT) = 0 AS v;

--- @test cast_true_is_1
--- @expect [{"v":1}]
--- @expect (PostgreSQL) [{"v":true}]
SELECT CAST(TRUE AS INT) = 1 AS v;

--- @test true_is_2
--- @expect [{"v":0}]
--- @expect (PostgreSQL) [{"v":false}]
SELECT CAST(TRUE AS INT) = 2 AS v;

--- @test add_true
--- @expect [{"v":2}]
--- @expect (PostgreSQL) error
SELECT TRUE + TRUE AS v;
