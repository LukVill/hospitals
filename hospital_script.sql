-- HOSPINFO AND HOSPITALS

SELECT * FROM HospInfo hi;

-- check duplicated hospital 

-- NOTE: THIS MERGING METHOD IS NOT THE MOST EFFICIENT BECAUSE:
-- formatting of address, some info could be excluded 
-- get database of matching hospitals based on address, assuming addresses are formatted the same way
select count(*) from HospInfo hi
inner join Hospitals h
on hi.Address = h.ADDRESS;

-- get count of total hospitals
select count(*) from HospInfo hi;
-- about half hospitals don't match, TABLEAU


SELECT * FROM Hospitals h;

-- get information of matching hospitals 
select * from HospInfo hi
inner join Hospitals h
on hi.Address = h.ADDRESS;

-- get number of nonmatching hospitals
select count(*) from HospInfo hi
WHERE hi."Provider ID" NOT IN (select "Provider ID"  from HospInfo hi
inner join Hospitals h
on hi.Address = h.ADDRESS);
-- TABLEAU

select count(*) from Hospitals h
WHERE h.OBJECTID NOT IN (select OBJECTID  from HospInfo hi
inner join Hospitals h
on hi.Address = h.ADDRESS);
-- TABLEAU

-- get total of hospitals of each database
SELECT count(*) FROM HospInfo hi;
SELECT count(*) FROM hospitals h;
--TABLEAU

-- CLEAN UP OTHER DATABASES FIRST


---- ROWS ANALYSIS

SELECT * FROM "rows" r;
SELECT count(*) FROM "rows" r;
-- each row is a branch of a hospital

-- unique hospitals count
SELECT count(DISTINCT Address) FROM "rows" r;

-- count of branches for each hospital
SELECT count(*) FROM "rows" r 
GROUP BY "Hospital Name";
-- TABLEAU as histogram or bar

-- look at score of rows and see if it's all numeric
select DISTINCT score from rows;

-- get list of non numeric values in scores in rows
SELECT distinct score, footnote from rows
where score glob '[A-Za-z]*';

-- get rows with only numeric values
with non_num as (select DISTINCT score from rows
where score glob '[A-Za-z]*')
select distinct cast(score as integer) as score from "rows" r
where Score not in non_num;

with non_num as (select DISTINCT score from rows
where score glob '[A-Za-z]*')
select * from "rows" r 
where Score not in non_num;


-- FINALIZED dataset of rows that have numeric rows
DROP TABLE IF EXISTS newRow;
create table newRow as select * from "rows" r 
where Score not in (select DISTINCT score from rows
where score glob '[A-Za-z]*');

-- count of newRow = hospitals in "rows" with valid scores
select count(*) from newRow;

-- vs the orginal hospitals in "rows"
select count(*) from rows;

-- how many hospitals had no valid scores?
select (select count(*) from rows)-count(*) from newRow;
-- about half hospitals did not have any valid scores


--## ANALYSIS of missing_score 
-- get rows with invalid scores
SELECT * FROM "rows" r 
where score glob '[A-Za-z]*';
DROP TABLE IF EXISTS missing_score;
CREATE TABLE missing_score AS SELECT * FROM "rows" r 
where score glob '[A-Za-z]*';
-- MISSING SCORES: table of either NA scores or non numeric scores, NA scores have footnote

-- make valid score datatable
SELECT * FROM "rows" r 
WHERE r."index" NOT IN (SELECT "index" FROM missing_score ms);
DROP TABLE IF EXISTS valid_score;
CREATE TABLE valid_score AS SELECT * FROM "rows" r 
WHERE r."index" NOT IN (SELECT "index" FROM missing_score ms);


-- which states had the most invalid scores?
SELECT State, count(*) AS missing_score_count FROM missing_score
GROUP BY state
ORDER BY count(*) DESC;

--## FOOTNOTE
-- foot note is a note if the score is considered missing
-- analyze ONLY footnotes from considered missing data (i.e. missing_score)

-- agg of footnotes
SELECT footnote, count(*) from missing_score ms 
GROUP BY footnote;
-- MAKE IN TABLEAU 

-- for the missing scores, whats the state count for missing footnotes?
SELECT state, count(*) from missing_score ms
GROUP BY state;
-- MAKE IN TABLEAU


---- END OF ROWS

SELECT * FROM HospInfo hi;
SELECT * FROM Hospitals h;
SELECT * FROM valid_score vs;

--hospinfo tells info on hospital basics (type, ownership, emergency services, overall rating)
--rows tells on branch scores
--hospitals showcase coordinates

SELECT * FROM HospInfo hi;
SELECT * FROM Hospitals h;
SELECT * FROM "rows" r;

-- combine dataframes on address on matching
SELECT * FROM HospInfo hi
INNER JOIN "rows" r
ON hi.Address = r.Address
INNER JOIN Hospitals h 
ON hi.Address = h.ADDRESS;


-- FINALIZED WRITE UP OF HOSP_DF
--DROP TABLE test;
--CREATE TABLE test AS SELECT * FROM HospInfo hi
--LIMIT 10;
--SELECT * FROM test;
-- HospInfo edits
ALTER TABLE HospInfo 
DROP COLUMN Location;
-- update mortality to make it sensible for Tableau
UPDATE HospInfo 
SET "Mortality national comparison" = 
CASE WHEN "Mortality national comparison" = "Below the national average" THEN "Low Mortality Rate"
WHEN "Mortality national comparison" = "Same as the national average" THEN "Average Mortality Rate"
WHEN "Mortality national comparison" = "Above the national average" THEN "High Mortality Rate"
ELSE "Not Available"
END;
UPDATE HospInfo 
SET "Safety of care national comparison" = 
CASE WHEN "Safety of care national comparison" = "Below the national average" THEN "Low Safety Score"
WHEN "Safety of care national comparison" = "Same as the national average" THEN "Average Safety Score"
WHEN "Safety of care national comparison" = "Above the national average" THEN "High Safety Score"
ELSE "Not Available"
END;
UPDATE HospInfo 
SET "Readmission national comparison" = 
CASE WHEN "Readmission national comparison" = "Below the national average" THEN "Low Readmission Rate"
WHEN "Readmission national comparison" = "Same as the national average" THEN "Average Readmission Rate"
WHEN "Readmission national comparison" = "Above the national average" THEN "High Readmission Rate"
ELSE "Not Available"
END;
UPDATE HospInfo 
SET "Patient experience national comparison" = 
CASE WHEN "Patient experience national comparison" = "Below the national average" THEN "Low Patient Experience Score"
WHEN "Patient experience national comparison" = "Same as the national average" THEN "Average Patient Experience Score"
WHEN "Patient experience national comparison" = "Above the national average" THEN "High Patient Experience Score"
ELSE "Not Available"
END;
UPDATE HospInfo 
SET "Effectiveness of care national comparison" = 
CASE WHEN "Effectiveness of care national comparison" = "Below the national average" THEN "Low Effectiveness"
WHEN "Effectiveness of care national comparison" = "Same as the national average" THEN "Average Effectiveness"
WHEN "Effectiveness of care national comparison" = "Above the national average" THEN "High Effectiveness"
ELSE "Not Available"
END;
UPDATE HospInfo 
SET "Timeliness of care national comparison" = 
CASE WHEN "Timeliness of care national comparison" = "Below the national average" THEN "Slow Speed of Care"
WHEN "Timeliness of care national comparison" = "Same as the national average" THEN "Average Speed of Care"
WHEN "Timeliness of care national comparison" = "Above the national average" THEN "Fast Speed of Care"
ELSE "Not Available"
END;
UPDATE HospInfo 
SET "Efficient use of medical imaging national comparison" = 
CASE WHEN "Efficient use of medical imaging national comparison" = "Below the national average" THEN "Low Imaging Efficiency"
WHEN "Efficient use of medical imaging national comparison" = "Same as the national average" THEN "Average Imaging Efficiency"
WHEN "Efficient use of medical imaging national comparison" = "Above the national average" THEN "High Imaging Efficiency"
ELSE "Not Available"
END;





-- Hospitals edits
ALTER TABLE Hospitals 
DROP COLUMN Location;

-- DROP IF EXISTS
DROP TABLE IF EXISTS hosp_df;

-- CREATE TABLE
CREATE TABLE hosp_df AS
SELECT * FROM HospInfo hi
INNER JOIN "rows" r
ON hi.Address = r.Address AND hi.City = r.City AND hi.State = r.State
INNER JOIN Hospitals h 
ON hi.Address = h.ADDRESS AND hi.City = h.CITY AND hi.State = r.STATE;
-- EACH ROW NOW IS A BRANCH SCORE 


-- ANALYSIS
SELECT * FROM hosp_df hd;


-- count of rows
SELECT count(*) FROM hosp_df;

-- count of matching hospitals
SELECT count(*) FROM hosp_df hd
GROUP BY "Hospital Name";
-- TABLEAU

-- check for missing values
SELECT count(distinct "Provider ID"), count(*) FROM HospInfo hi;
SELECT count("Hospital Name"), count(*) FROM HospInfo hi;
SELECT count(DISTINCT "Hospital Name"), count(*) FROM HospInfo hi;
-- same hospital multiple times
SELECT count(DISTINCT "Address"), count(*) FROM HospInfo hi;
-- address duplicate count doesn't match the hospital
SELECT DISTINCT "Provider ID" FROM hosp_df hd
WHERE "Provider ID" IS NULL;


-- Analysis to show in Tableau




