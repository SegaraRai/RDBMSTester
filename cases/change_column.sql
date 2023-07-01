--- @schema
--- @skip (!MariaDB)
CREATE TABLE tableA (id INT PRIMARY KEY);
CREATE TABLE tableB (id INT PRIMARY KEY, ref_id INT REFERENCES tableA(id), test INT);

--- @test change_column_no_rename
--- @reset
ALTER TABLE tableB CHANGE COLUMN test test INT;

--- @test change_column_rename
--- @reset
ALTER TABLE tableB CHANGE COLUMN test test2 INT;

--- @test change_column_rename_conflict
--- @expect error
--- @reset
ALTER TABLE tableB CHANGE COLUMN test ref_id INT;

--- @test change_column_not_null
--- @reset
ALTER TABLE tableB CHANGE COLUMN test test INT NOT NULL;

--- @test change_column_no_references
--- @reset
ALTER TABLE tableB CHANGE COLUMN ref_id ref_id INT;

--- @test insert
--- @expect error
--- @reset
INSERT INTO tableB (id, ref_id, test) VALUES (1, 1, 1);

--- @test change_column_no_references_insert
--- @expect error
--- @reset
--- @note this indicates that `CHANGE COLUMN` does not drop the foreign key constraint
ALTER TABLE tableB CHANGE COLUMN ref_id ref_id INT;
INSERT INTO tableB (id, ref_id, test) VALUES (1, 1, 1);

--- @test change_column_duplicated_references
--- @expect error
--- @reset
--- @note this results in a syntax error
ALTER TABLE tableB CHANGE COLUMN ref_id ref_id INT REFERENCES tableA(id);
