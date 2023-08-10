--- @schema
CREATE TABLE t1 (id1 INT PRIMARY KEY, a INT);
CREATE TABLE t2 (id2 INT PRIMARY KEY, a INT);
CREATE TABLE t3 (id3 INT PRIMARY KEY, a INT);
INSERT INTO t1 (id1, a) VALUES (11, 1), (12, 2), (13, 3);
INSERT INTO t2 (id2, a) VALUES (21, 1), (22, 2), (23, 4);
INSERT INTO t3 (id3, a) VALUES (31, 1), (32, 2), (33, 5);

--- @test join_using
--- @expect [{"a":1,"id1":11,"id2":21},{"a":2,"id1":12,"id2":22}]
--- @expect (SQLite) [{"id1":11,"a":1,"id2":21},{"id1":12,"a":2,"id2":22}]
SELECT * FROM t1 JOIN t2 USING (a);

--- @test join_using_where_no_table
--- @expect [{"a":1,"id1":11,"id2":21}]
--- @expect (SQLite) [{"id1":11,"a":1,"id2":21}]
SELECT * FROM t1 JOIN t2 USING (a) WHERE a = 1;

--- @test join_using_where_left_table
--- @expect [{"a":1,"id1":11,"id2":21}]
--- @expect (SQLite) [{"id1":11,"a":1,"id2":21}]
SELECT * FROM t1 JOIN t2 USING (a) WHERE t1.a = 1;

--- @test join_using_where_right_table
--- @expect [{"a":1,"id1":11,"id2":21}]
--- @expect (SQLite) [{"id1":11,"a":1,"id2":21}]
SELECT * FROM t1 JOIN t2 USING (a) WHERE t2.a = 1;
