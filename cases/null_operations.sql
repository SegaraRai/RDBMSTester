--- @schema

--- @test basic
--- @expect [{"v":0}]
--- @expect (PostgreSQL) [{"v":false}]
SELECT (1 > 2) AS v;

--- @test null_comparison_eq_rh
--- @expect [{"v":null}]
SELECT (1 = NULL) AS v;

--- @test null_comparison_eq_lh
--- @expect [{"v":null}]
SELECT (NULL = 1) AS v;

--- @test null_comparison_gt_rh
--- @expect [{"v":null}]
SELECT (1 > NULL) AS v;

--- @test null_comparison_gt_lh
--- @expect [{"v":null}]
SELECT (NULL < 1) AS v;

--- @test null_and_true
--- @expect [{"v":null}]
SELECT (NULL AND TRUE) AS v;

--- @test null_or_false
--- @expect [{"v":null}]
SELECT (NULL OR FALSE) AS v;

--- @test null_comparison_is_null
--- @expect [{"v":1}]
--- @expect (PostgreSQL) [{"v":true}]
SELECT ((1 = NULL) IS NULL) AS v;

--- @test len_null
--- @expect [{"v":null}]
SELECT LENGTH(NULL) AS v;
