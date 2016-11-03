/**
 * SQL implementation of HW6
 */ -- Part 1: Create a database Hw6 that has a single table called flight.

DROP DATABASE IF EXISTS hw6;


CREATE DATABASE hw6;

USE hw6;

-- FLIGHTS (
--      fid, year, month_id, day_of_month,
--      day_of_week_id, carrier_id, flight_num, origin_city,
--      origin_state, dest_city, dest_state, departure_delay,
--      taxi_out, arrival_delay, canceled, actual_time, distance)
 -- drop the table first

DROP TABLE IF EXISTS flights;

-- create table

CREATE TABLE flights (
    fid INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    year_id INT NOT NULL,
    month_id INT NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week_id INT NOT NULL,
    carrier_id VARCHAR(10) NOT NULL,
    flight_num INT NOT NULL,
    origin_city VARCHAR(200) NOT NULL,
    origin_state VARCHAR(200) NOT NULL,
    dest_city VARCHAR(200) NOT NULL,
    dest_state VARCHAR(200) NOT NULL,
    departure_delay INT, taxi_out INT,
    arrival_delay INT,
    cancelled TINYINT(1) NOT NULL DEFAULT 0,
    actual_time INT,
    distance INT NOT NULL
);

-- Part 2:
 -- Query 1 :For each origin city, find the destination city (or cities)
--     with the longest direct flight. By direct flight, we mean a flight
--     with no intermediate stops. Judge the longest flight in time, not distance.
--     Show the name of the origin city, destination city, and the flight time
--     between them. Do not include duplicates of the same origin/destination
--     city pair. Order the result by origin_city name then destination city name.
--
-- Affected rows: 0  Found rows: 257  Warnings: 0  Duration for 1 query: 0.860 sec.

SELECT origin_city,
       dest_city,
       MAX(actual_time) AS actual_time
FROM flights
WHERE origin_city NOT LIKE '%/%'
    AND dest_city NOT LIKE '%/%'
    AND fid NOT IN
        ( SELECT a.fid AS fid
         FROM
             (SELECT fid,
                     origin_city,
                     dest_city,
                     MAX(actual_time) AS actual_time
              FROM flights
              WHERE origin_city NOT LIKE '%/%'
                  AND dest_city NOT LIKE '%/%'
              GROUP BY origin_city) a
         JOIN
             (SELECT dest_city AS city1,
                     origin_city AS city2,
                     MAX(actual_time) AS actual_time
              FROM flights
              WHERE origin_city NOT LIKE '%/%'
                  AND dest_city NOT LIKE '%/%'
              GROUP BY origin_city) b ON a.origin_city = b.city1
         AND a.dest_city = b.city2)
GROUP BY origin_city
ORDER BY origin_city,
         dest_city;

-- Query 2:
--      Find all origin cities that only serve flights shorter than 3 hours.
--      You can assume that flights with NULL actual_time are not 3 hours or more.
--      Return only the names of the cities sorted by name.
--      List each city only once in the result.
-- Affected rows: 0  Found rows: 122  Warnings: 0  Duration for 1 query: 0.125 sec.

SELECT DISTINCT origin_city
FROM flights
WHERE actual_time IS NOT NULL
    AND actual_time/60 >= 3.0;

-- Query 3:
--      Create a view called short_flights that has all the info for
--      flights where the distance is less the 300
-- Affected rows: 0  Found rows: 0  Warnings: 0  Duration for 1 query: 0.000 sec.

DROP VIEW IF EXISTS short_flights;

-- Affected rows: 0  Found rows: 0  Warnings: 0  Duration for 1 query: 0.016 sec.

CREATE VIEW short_flights AS
SELECT *
FROM flights
WHERE distance < 300;

-- Part 3 Physical Tuning
 /* In this part you will be asked to examine the query plan of a SQL query. Take the following 3 queries:
 SELECT DISTINCT carrier_id
  FROM Flights
  WHERE origin_city = 'Seattle WAâ AND actual_time <= 180;

 SELECT DISTINCT carrier_id
  FROM Flights
  WHERE origin_city = 'Gunnison CO' AND   actual_time <= 180;

 SELECT DISTINCT carrier_id
  FROM Flights
  WHERE origin_city = 'Seattle WAâ AND actual_time <= 30;
*/ -- 1. Run the above queries and document the time
-- Affected rows: 0  Found rows: 9  Warnings: 0  Duration for 1 query: 0.094 sec.

SELECT DISTINCT carrier_id
FROM Flights
WHERE origin_city = 'Seattle WA'
    AND actual_time <= 180;

-- Affected rows: 0  Found rows: 1  Warnings: 0  Duration for 1 query: 0.078 sec.

SELECT DISTINCT carrier_id
FROM Flights
WHERE origin_city = 'Gunnison CO'
    AND actual_time <= 180;

-- Affected rows: 0  Found rows: 0  Warnings: 0  Duration for 1 query: 0.078 sec.

SELECT DISTINCT carrier_id
FROM Flights
WHERE origin_city = 'Seattle WA'
    AND actual_time <= 30;

-- 2. Choose one single simple index (index on one attribute)
--    that is most likely to speed up all three queries.
--    Create the index.  Use Alter table command to create index.
--    (ALTER TABLE TABLE_NAME ADD INDEX (COLUMN_NAME);)
 -- Affected rows: 0  Found rows: 0  Warnings: 0  Duration for 1 query: 0.500 sec.
-- CREATE INDEX idx_origin_city ON flights (origin_city);
-- DROP INDEX idx_origin_city ON flights
-- Affected rows: 0  Found rows: 0  Warnings: 0  Duration for 1 query: 0.219 sec.

CREATE INDEX idx_actual_time ON flights (actual_time);

-- DROP INDEX idx_actual_time ON flights
 -- 3.Rerun the queries.
--   Look at the time and the plan.
--   Copy into the deliverable document.
-- Affected rows: 0  Found rows: 9  Warnings: 0  Duration for 1 query: 0.515 sec.

SELECT DISTINCT carrier_id
FROM Flights
WHERE origin_city = 'Seattle WA'
    AND actual_time <= 180;

-- Affected rows: 0  Found rows: 1  Warnings: 0  Duration for 1 query: 0.453 sec.

SELECT DISTINCT carrier_id
FROM Flights
WHERE origin_city = 'Gunnison CO'
    AND actual_time <= 180;

-- Affected rows: 0  Found rows: 0  Warnings: 0  Duration for 1 query: 0.000 sec.

SELECT DISTINCT carrier_id
FROM Flights
WHERE origin_city = 'Seattle WA'
    AND actual_time <= 30;

-- 4. Consider this query:
--    SELECT DISTINCT F2.origin_city
--      FROM Flights F1, Flights F2
--     WHERE F1.dest_city = F2.dest_city
--       AND F1.origin_city='Gunnison CO'
--       AND F1.actual_time <= 30;
 -- Run the query with the index added in question 2
-- and then drop the index and run again.
-- Any difference in time?
 -- W/ index:
-- Affected rows: 0  Found rows: 0  Warnings: 0  Duration for 1 query: 0.000 sec.

SELECT DISTINCT F2.origin_city
FROM Flights F1,
     Flights F2
WHERE F1.dest_city = F2.dest_city
    AND F1.origin_city='Gunnison CO'
    AND F1.actual_time <= 30;

-- Drop the index

DROP INDEX idx_actual_time ON flights;

-- W/o index:
-- Affected rows: 0  Found rows: 0  Warnings: 0  Duration for 1 query: 0.094 sec.

SELECT DISTINCT F2.origin_city
FROM Flights F1,
     Flights F2
WHERE F1.dest_city = F2.dest_city
    AND F1.origin_city='Gunnison CO'
    AND F1.actual_time <= 30;

-- 5. Rerun the queries from Part 1.
--    Compare the results after you add some indexes.
-- a. w/ idx_actual_time
-- Affected rows: 0  Found rows: 257  Warnings: 0  Duration for 1 query: 0.875 sec.

CREATE INDEX idx_origin_dest_time_city ON flights (origin_city, dest_city, actual_time);

-- DROP INDEX idx_origin_dest_time_city ON flights;
-- b. w/ idx_origin_dest_time_city
-- Affected rows: 0  Found rows: 256  Warnings: 0  Duration for 1 query: 0.329 sec.
 -- Part 4 Cardinality and Selectivity
 -- 1. What would the cardinality and selectivity be for the column dest_state?
--    dest_state: 0.05%
-- 2. What would the cardinality and selectivity be for the column day_of_week?
--    day_of_week: 0.006%
-- 3. What would the cardinality and selectivity be for the column origin_city?
--    origin_city: 0.30%
