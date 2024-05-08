-- 3.1
-- ????????????????????????
-- Do they want cook_id or cook_name?
-- Do they want it like that in 1 table? Do they want 2 tables? Do they want 1 table with 3 attributes and null values?
-- ????????????????????????
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'contestant_name/national_cuisine', AVG(grade)
FROM evaluation
JOIN cooks ON contestant_id=cook_id
GROUP BY 1
UNION
SELECT type_of_national_cuisine_that_belongs_to, AVG(grade)
FROM evaluation
JOIN cooks_belongs_to_national_cuisine ON contestant_id=cook_id
GROUP BY type_of_national_cuisine_that_belongs_to;

-- 3.2
-- ???????????
-- What do they want? 1 or 2 tables + what in its case + what does given mean ...
-- ???????????
SELECT DISTINCT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name', type_of_national_cuisine_that_belongs_to 'National Cuisine', current_year 'Year of the episode'
FROM cooks
JOIN cooks_recipes_per_episode USING (cook_id)
JOIN cooks_belongs_to_national_cuisine USING (cook_id)
WHERE current_year=2000 AND type_of_national_cuisine_that_belongs_to='Greek';

-- 3.3
DROP TABLE IF EXISTS `rec_count`;

CREATE TEMPORARY TABLE rec_count
SELECT cook_id,COUNT(rec_name) recipe_count
FROM cooks_recipes_per_episode
JOIN cooks USING (cook_id)
WHERE age<30
GROUP BY cook_id;

SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name', recipe_count
FROM rec_count
JOIN cooks USING (cook_id)
WHERE recipe_count=(SELECT MAX(recipe_count) 
					FROM rec_count);
                    
DROP TABLE rec_count; 

-- 3.4
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name'
FROM cooks
WHERE cook_id NOT IN (SELECT cook_id
						FROM judges); 
                        
-- 3.5
DROP TABLE IF EXISTS `appearances`;

CREATE TEMPORARY TABLE appearances
SELECT current_year , CONCAT(name_of_cook,' ',surname_of_cook) Cook_name, COUNT(episode_number) Number_of_Appearances
FROM judges
JOIN cooks USING (cook_id)
GROUP BY current_year, Cook_name
HAVING Number_of_Appearances>3
ORDER BY current_year, Number_of_Appearances;


SELECT a.current_year, a.Cook_name, a.Number_of_Appearances
FROM appearances a
JOIN ( SELECT current_year, Number_of_Appearances, COUNT(Cook_name) apps_count
		FROM appearances
		GROUP BY current_year, Number_of_Appearances
		HAVING apps_count>1) b USING (current_year, Number_of_Appearances);
        
DROP TABLE appearances;






-- created a test database to test the queries without needing to worry about foreign key constraints
-- if you go further down you will find the exercise queries for the test database 

DROP DATABASE IF EXISTS `test`;
CREATE DATABASE `test`; 
USE `test`;

CREATE TABLE cooks_belongs_to_national_cuisine(
cook_id INT(11) ,
type_of_national_cuisine_that_belongs_to VARCHAR(50),
PRIMARY KEY (cook_id,type_of_national_cuisine_that_belongs_to)
);

INSERT INTO cooks_belongs_to_national_cuisine
VALUES (1,'Greek'),
		(2,'Greek'),
        (3,'French'),
        (4,'Danish'),
        (5,'French'),
        (6,'Saudi Arabian'),
        (7,'Italian'),
		(10,'German');

CREATE TABLE evaluation(
current_year INT(11) ,
episode_number INT(11) ,
contestant_id INT(11) ,
judge_id INT(11) , 
grade INT(11) NOT NULL CHECK (grade IN (1,2,3,4,5)),
PRIMARY KEY (current_year,episode_number,contestant_id,judge_id)
);

INSERT INTO evaluation
VALUES (2000,1,1,10,4),
		(2000,1,1,4,3),
        (2000,1,1,5,4),
        (2000,1,2,10,5),
        (2000,1,2,4,3),
        (2000,1,2,5,4),
        (2000,1,3,10,1),
        (2000,1,3,4,2),
        (2000,1,3,5,3),
        (2001,3,10,1,3),
        (2001,3,10,6,2),
        (2001,3,10,7,2),
		(2001,2,10,1,3),
        (2001,2,10,6,2),
        (2001,2,10,7,5);

CREATE TABLE cooks(
cook_id INT(11),
name_of_cook VARCHAR(50),
surname_of_cook VARCHAR(50),
phone_number VARCHAR(50),
date_of_birth date,
age INT(11),
years_of_experience INT(11) CHECK(years_of_experience>0),
cook_category VARCHAR(50) CHECK(cook_category IN ('C Cook', 'B Cook', 'A Cook', 'Chef', "Chef's Assistant")),
PRIMARY KEY (cook_id)
);

INSERT INTO cooks
VALUES (1,'George','Markoulidakis',NULL,'2003-12-30',21,10,'Chef'),
		(2,'Nikos','Anagnostou',NULL,'2003-2-24',21,2,'C Cook'),
        (3,'Ilias','Makras',NULL,'2003-5-23',21,3,'C Cook'),
        (4,'Luke','Skywalker',NULL,NULL,80,50,'A Cook'),
        (5,'Darth','Vader',NULL,NULL,104,40,'B Cook'),
        (6,'Leia','Organa',NULL,NULL,80,60,"Chef's Assistant"),
        (7,'Padme','Amidala',NULL,NULL,134,100,'Chef'),
        (10,'Joe','Mama',NULL,NULL,75,46,"Chef's Assistant");


CREATE TABLE episodes_per_year(
current_year INT(11),
episode_number INT(11),
PRIMARY KEY(current_year,episode_number)
);

INSERT INTO episodes_per_year
VALUES (2000,1),
		(2001,1),
		(2001,2),
        (2001,3);


CREATE TABLE cooks_recipes_per_episode(
current_year INT(11) ,
episode_number INT(11) ,
rec_name VARCHAR(50),
cook_id INT(11),
PRIMARY KEY (current_year,episode_number,cook_id)
); 

INSERT INTO cooks_recipes_per_episode
VALUES (2000,1,'Paidakia',1),
		(2000,1,'Rice',2),
        (2000,1,'Ice Cream',3),
        (2001,1,'Chicken Soup',1),
        (2001,2,'Joe Dada',10),
		(2001,3,'Cookies',10);
        
CREATE TABLE judges (
current_year INT(11) ,
episode_number INT(11) ,
cook_id INT(11),
PRIMARY KEY (current_year,episode_number,cook_id)
);

INSERT INTO judges
VALUES (2000,1,10),
		(2000,1,4),
        (2000,1,5),
        (2001,1,10),
        (2001,1,6),
        (2001,1,7),
		(2001,2,1),
        (2001,2,6),
        (2001,2,7),
        (2001,3,1),
        (2001,3,6),
        (2001,3,7);
        
-- 3.1
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'contestant_name/national_cuisine', AVG(grade)
FROM evaluation
JOIN cooks ON contestant_id=cook_id
GROUP BY 1
UNION
SELECT type_of_national_cuisine_that_belongs_to, AVG(grade)
FROM evaluation
JOIN cooks_belongs_to_national_cuisine ON contestant_id=cook_id
GROUP BY type_of_national_cuisine_that_belongs_to;
        
-- 3.2
SELECT DISTINCT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name', type_of_national_cuisine_that_belongs_to 'National Cuisine', current_year 'Year of the episode'
FROM cooks
JOIN cooks_recipes_per_episode USING (cook_id)
JOIN cooks_belongs_to_national_cuisine USING (cook_id)
WHERE current_year=2000 AND type_of_national_cuisine_that_belongs_to='Greek';

-- 3.3
DROP TABLE IF EXISTS `rec_count`;

CREATE TEMPORARY TABLE rec_count
SELECT cook_id,COUNT(rec_name) recipe_count
FROM cooks_recipes_per_episode
JOIN cooks USING (cook_id)
WHERE age<30
GROUP BY cook_id;

SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name', recipe_count
FROM rec_count
JOIN cooks USING (cook_id)
WHERE recipe_count=(SELECT MAX(recipe_count) 
					FROM rec_count);
                    
DROP TABLE rec_count;      
     
-- 3.4
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name'
FROM cooks
WHERE cook_id NOT IN (SELECT cook_id
						FROM judges); 
                        
-- 3.5
DROP TABLE IF EXISTS `appearances`;

CREATE TEMPORARY TABLE appearances
SELECT current_year , CONCAT(name_of_cook,' ',surname_of_cook) Cook_name, COUNT(episode_number) Number_of_Appearances
FROM judges
JOIN cooks USING (cook_id)
GROUP BY current_year, Cook_name
-- HAVING Number_of_Appearances>3
-- this is commented here because no judge has appeared more than 3 times so there is no reason to put it
ORDER BY current_year, Number_of_Appearances;


SELECT a.current_year, a.Cook_name, a.Number_of_Appearances
FROM appearances a
JOIN ( SELECT current_year, Number_of_Appearances, COUNT(Cook_name) apps_count
		FROM appearances
		GROUP BY current_year, Number_of_Appearances
		HAVING apps_count>1) b USING (current_year, Number_of_Appearances);
        
DROP TABLE appearances;
