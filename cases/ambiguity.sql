--- @schema
CREATE TABLE tableA (id INT PRIMARY KEY);
CREATE TABLE tableB (id INT PRIMARY KEY, ref_id INT REFERENCES tableA(id));

--- @test select_ambiguous_column
--- @expect error
SELECT id FROM tableA JOIN tableB ON tableA.id = tableB.id;

--- @test select_ambiguous_column_table_alias
--- @expect error
SELECT id FROM tableA a JOIN tableB b ON a.id = b.id;

--- @test select_column_qualified
SELECT tableA.id FROM tableA JOIN tableB ON tableA.id = tableB.id;

--- @test select_column_qualified_table_alias
SELECT a.id FROM tableA a JOIN tableB b ON a.id = b.id;

--- @test on_ambiguous_column
--- @expect error
SELECT tableA.id FROM tableA JOIN tableB ON tableA.id = id;

--- @test on_ambiguous_column_alias
--- @expect error
SELECT tableA.id AS id FROM tableA JOIN tableB ON tableB.id = id;

--- @test order_by_ambiguous_column
--- @expect (SQLite) error
SELECT tableA.id FROM tableA JOIN tableB ON tableA.id = tableB.id ORDER BY id;

--- @test order_by_column_alias
SELECT tableA.id AS id FROM tableA JOIN tableB ON tableA.id = tableB.id ORDER BY id;

--- @test where_ambiguous_column
--- @expect error
SELECT tableA.id FROM tableA JOIN tableB ON tableA.id = tableB.id WHERE id = 1;

--- @test where_column_alias
--- @expect error
SELECT tableA.id AS id FROM tableA JOIN tableB ON tableA.id = tableB.id WHERE id = 1;
