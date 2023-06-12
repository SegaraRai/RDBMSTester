--- @schema
CREATE TABLE tableA (id INT PRIMARY KEY);
CREATE TABLE tableB (id INT PRIMARY KEY, ref_id INT REFERENCES tableA(id));

--- @test safe_on
SELECT tableA.id AS id FROM tableA JOIN tableB ON tableA.id = tableB.ref_id;

--- @test ambiguous_on
--- @expect error
SELECT tableA.id AS id FROM tableA JOIN tableB ON id = tableB.ref_id;

--- @test safe_aliased_on
SELECT tableA.id AS a_id FROM tableA JOIN tableB ON tableA.id = tableB.ref_id;

--- @test aliased_on
--- @expect (!SQLite) error
SELECT tableA.id AS a_id FROM tableA JOIN tableB ON a_id = tableB.ref_id;

--- @test safe_where
SELECT tableA.id AS id FROM tableA JOIN tableB ON tableA.id = tableB.ref_id WHERE tableA.id = 1;

--- @test ambiguous_where
--- @expect error
SELECT tableA.id AS id FROM tableA JOIN tableB ON tableA.id = tableB.ref_id WHERE id = 1;

--- @test safe_aliased_where
SELECT tableA.id AS a_id FROM tableA JOIN tableB ON tableA.id = tableB.ref_id WHERE tableA.id = 1;

--- @test aliased_where
--- @expect (!SQLite) error
SELECT tableA.id AS a_id FROM tableA JOIN tableB ON tableA.id = tableB.ref_id WHERE a_id = 1;
