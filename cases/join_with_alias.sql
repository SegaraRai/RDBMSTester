--- @schema
CREATE TABLE t1 (id1 INT PRIMARY KEY, a INT);
CREATE TABLE t2 (id2 INT PRIMARY KEY, b INT);
CREATE TABLE t3 (id3 INT PRIMARY KEY, c INT);
INSERT INTO t1 (id1, a) VALUES (11, 1), (12, 2), (13, 3);
INSERT INTO t2 (id2, b) VALUES (21, 1), (22, 2), (23, 4);
INSERT INTO t3 (id3, c) VALUES (31, 1), (32, 2), (33, 5);

--- @test join_without_alias
--- @expect [{"id1":11,"a":1,"id2":21,"b":1},{"id1":12,"a":2,"id2":22,"b":2}]
SELECT * FROM t1 JOIN t2 ON t1.a = t2.b;

--- @test join_with_alias
--- @expect [{"id1":11,"a":1,"id2":21,"b":1},{"id1":12,"a":2,"id2":22,"b":2}]
SELECT * FROM t1 AS ta JOIN t2 AS tb ON ta.a = tb.b;

--- @test join_with_alias_shorthand
--- @expect [{"id1":11,"a":1,"id2":21,"b":1},{"id1":12,"a":2,"id2":22,"b":2}]
SELECT * FROM t1 ta JOIN t2 tb ON ta.a = tb.b;

--- @test multiple_join_without_alias
--- @expect [{"id1":11,"a":1,"id2":21,"b":1,"id3":31,"c":1},{"id1":12,"a":2,"id2":22,"b":2,"id3":32,"c":2}]
SELECT * FROM t1 JOIN t2 ON t1.a = t2.b JOIN t3 ON t2.b = t3.c;

--- @test multiple_join_with_alias
--- @expect [{"id1":11,"a":1,"id2":21,"b":1,"id3":31,"c":1},{"id1":12,"a":2,"id2":22,"b":2,"id3":32,"c":2}]
SELECT * FROM t1 AS ta JOIN t2 AS tb ON ta.a = tb.b JOIN t3 AS tc ON tb.b = tc.c;

--- @test multiple_join_with_alias_shorthand
--- @expect [{"id1":11,"a":1,"id2":21,"b":1,"id3":31,"c":1},{"id1":12,"a":2,"id2":22,"b":2,"id3":32,"c":2}]
SELECT * FROM t1 ta JOIN t2 tb ON ta.a = tb.b JOIN t3 tc ON tb.b = tc.c;

--- @test nested_join_without_alias
--- @expect [{"id1":11,"a":1,"id2":21,"b":1,"id3":31,"c":1},{"id1":12,"a":2,"id2":22,"b":2,"id3":32,"c":2}]
SELECT * FROM t1 JOIN (t2 JOIN t3 ON t2.b = t3.c) ON t1.a = t3.c;

--- @test nested_join_with_alias
--- @expect [{"id1":11,"a":1,"id2":21,"b":1,"id3":31,"c":1},{"id1":12,"a":2,"id2":22,"b":2,"id3":32,"c":2}]
SELECT * FROM t1 AS ta JOIN (t2 AS tb JOIN t3 AS tc ON tb.b = tc.c) ON ta.a = tc.c;

--- @test nested_join_with_alias_shorthand
--- @expect [{"id1":11,"a":1,"id2":21,"b":1,"id3":31,"c":1},{"id1":12,"a":2,"id2":22,"b":2,"id3":32,"c":2}]
SELECT * FROM t1 ta JOIN (t2 tb JOIN t3 tc ON tb.b = tc.c) ON ta.a = tc.c;

--- @test nested_join_extra_alias1
--- @expect [{"id1":11,"a":1,"id2":21,"b":1,"id3":31,"c":1},{"id1":12,"a":2,"id2":22,"b":2,"id3":32,"c":2}]
--- @expect (MariaDB) error
SELECT * FROM t1 AS ta JOIN (t2 AS tb JOIN t3 AS tc ON tb.b = tc.c) AS tx ON ta.a = tx.c;

--- @test nested_join_extra_alias2
--- @expect [{"id1":11,"a":1,"id2":21,"b":1,"id3":31,"c":1},{"id1":12,"a":2,"id2":22,"b":2,"id3":32,"c":2}]
--- @expect (!SQLite) error
SELECT * FROM t1 AS ta JOIN (t2 AS tb JOIN t3 AS tc ON tb.b = tc.c) AS tx ON ta.a = tc.c;
