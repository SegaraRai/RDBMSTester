--- @schema
CREATE TABLE tableA (id INT PRIMARY KEY);
CREATE TABLE tableB (id INT PRIMARY KEY, ref_id INT REFERENCES tableA(id));

--- @test mixed_select
--- @expect error
SELECT tableA.id FROM tableA a;

--- @test aliased
SELECT a.id FROM tableA a JOIN tableB b ON a.id = b.ref_id;

--- @test mixed_select
--- @expect error
SELECT tableA.id FROM tableA a JOIN tableB b ON a.id = b.ref_id;

--- @test mixed_on
--- @expect error
SELECT a.id FROM tableA a JOIN tableB b ON a.id = tableB.ref_id;

--- @test mixed_where
--- @expect error
SELECT a.id FROM tableA a JOIN tableB b ON a.id = b.ref_id WHERE tableA.id = 1;

--- @test mixed_group_by
--- @expect error
SELECT a.id FROM tableA a JOIN tableB b ON a.id = b.ref_id GROUP BY tableA.id;

--- @test mixed_having
--- @skip
SELECT a.id FROM tableA a JOIN tableB b ON a.id = b.ref_id HAVING tableA.id = 1;

--- @test mixed_order_by
--- @expect error
SELECT a.id FROM tableA a JOIN tableB b ON a.id = b.ref_id ORDER BY tableA.id;
