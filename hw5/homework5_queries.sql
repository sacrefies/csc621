USE world;

-- 1. Write a query that displays the city and country names,
--    and populations from cities that have at least
--    200,000 people and less than 250,000 people.
SELECT city.name, country.name AS countryname, city.Population
FROM city
JOIN country ON city.countrycode = country.code
WHERE city.population >= 200000 AND city.population < 250000;


-- 2. Write a query that shows the countries where 8 or more
--    languages are spoken, and how many languages are spoken
--    in that country.
SELECT c.Code, c.Name, COUNT(cl.`Language`)
FROM country c
JOIN countrylanguage cl ON c.Code = cl.CountryCode
GROUP BY c.Code
HAVING COUNT(cl.`Language`) >= 8;


-- 3. Write a query that displays the population,
--    names and countries (name and ID) of the
--    largest city in each country.
SELECT cn.Code, cn.Name, c.Name AS cityname, c.ID AS cityid, MAX(c.Population)
FROM country cn
JOIN city c ON cn.Code = c.CountryCode
GROUP BY cn.code;


-- 4. Write a query that displays the names of cities
--    and their countries where the capital city
--    in the largest of all cities listed for that country.
--    (Hint: you can use the answer from 3)
SELECT c.ID, c.Name, cn.Name AS countryname, c.Population
FROM city c
JOIN country cn ON (cn.Code = c.CountryCode AND cn.Capital = c.ID)
JOIN (
SELECT c1.ID AS cityid, MAX(c1.Population)
FROM country cn1
JOIN city c1 ON cn1.Code = c1.CountryCode
GROUP BY cn1.code) largestcities ON largestcities.cityid = c.ID
