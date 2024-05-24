-- 3.1
-- Μέση βαθμολογία ανά μάγειρα.
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Contestant Name', AVG(grade)
FROM evaluation
JOIN cooks ON contestant_id=cook_id
GROUP BY 1;

-- Μέση βαθμολογία ανά εθνική κουζίνα.
SELECT national_cuisine 'National Cuisine', AVG(grade)
FROM cooks_recipes_per_episode a
JOIN recipe USING (rec_name)
JOIN evaluation b ON (a.current_year,a.episode_number,a.cook_id)=(b.current_year,b.episode_number,b.contestant_id)
GROUP BY national_cuisine;

-- 3.2
SELECT DISTINCT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name', 
						type_of_national_cuisine_that_belongs_to 'National Cuisine', 
                        current_year 'Year of the episode'
FROM cooks
JOIN cooks_recipes_per_episode USING (cook_id)
JOIN cooks_belongs_to_national_cuisine USING (cook_id)
JOIN recipe USING (rec_name)
WHERE current_year=2022 AND type_of_national_cuisine_that_belongs_to='Ainu' 
AND national_cuisine='Ainu' -- This condition is to check if the cook actually represents this national cuisine on an episode. 
-- If we do not want that we can comment it out. 
-- Then the query would find any cook that belongs to this national cuisine and participated to an episode that year, even if
-- the cook represented another national cuisine.
;

-- 3.3
-- Θεωρούμε ότι η φράση, "που έχουν τις περισσότερες συνταγές",
-- σημαίνει "που έχουν εκετελέσει τις περισσότερες διαφορετικές συνταγές στον διαγωνισμό".
WITH rec_count AS (SELECT cook_id,COUNT(DISTINCT rec_name) recipe_count
					FROM cooks_recipes_per_episode
					JOIN cooks USING (cook_id)
					WHERE age<30
					GROUP BY cook_id
					) -- this subquery finds how many different recipes each cook has cooked in the competition.
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Cook name', recipe_count
FROM rec_count
JOIN cooks USING (cook_id)
WHERE recipe_count=(SELECT MAX(recipe_count) -- keep only the cooks with the highest recipe_count (could be more than 1 cook, in case of a draw)
					FROM rec_count);


-- 3.4
SELECT CONCAT(name_of_cook,' ',surname_of_cook) 'Cooks that have never been a judge'
FROM cooks
WHERE cook_id NOT IN (SELECT cook_id
						FROM judges); 
                        
-- 3.5
-- Το να τύχει ένας κριτής να συμμετάσχει πάνω από 3 φορές σε ένα έτος είναι μεν εφικτό, είναι δε αρκετά απίθανο.
WITH appearances AS (
	SELECT current_year , CONCAT(name_of_cook,' ',surname_of_cook) Cook_name, COUNT(episode_number) Number_of_Appearances
	FROM judges
	JOIN cooks USING (cook_id)
	GROUP BY current_year, Cook_name
	HAVING Number_of_Appearances>3
	ORDER BY current_year, Number_of_Appearances) -- this subquery finds the number appearances of its judge per year.
SELECT a.current_year, a.Cook_name, a.Number_of_Appearances
FROM appearances a
JOIN ( SELECT current_year, Number_of_Appearances, COUNT(Cook_name) apps_count
		FROM appearances
		GROUP BY current_year, Number_of_Appearances
		HAVING apps_count>1) b USING (current_year, Number_of_Appearances) -- this subquery finds which number of appearances that appear more than once.
        ;
        

-- 3.6
-- ++++ force index
SELECT a_tag_name, b_tag_name, COUNT(*) Tag_Couple_Appearances
FROM(
	SELECT a.tag_name a_tag_name, b.tag_name b_tag_name
	FROM cooks_recipes_per_episode competition
	JOIN tags a USING (rec_name)
	JOIN tags b ON a.rec_name=b.rec_name AND a.tag_name<b.tag_name
) possible_couples_of_tags -- this subquery finds the possible couples of tags that appeared in the competition. 
							-- The couple is contained in the query as many times as it appears in the competition.
GROUP BY a_tag_name, b_tag_name
ORDER BY Tag_Couple_Appearances DESC
LIMIT 3;

-- 3.7
WITH cooks_apps AS(
	SELECT cook_id, COUNT(episode_number) Number_of_Appearances
	FROM cooks_recipes_per_episode
	GROUP BY cook_id) -- This subquery finds the number of appearances of each cook. 
SELECT CONCAT(name_of_cook,' ',surname_of_cook) Cook_name, Number_of_Appearances
FROM cooks_apps
JOIN cooks USING (cook_id)
HAVING Number_of_Appearances +5 <= (
	SELECT MAX(Number_of_Appearances) max_apps
	FROM cooks_apps);

-- 3.8
-- ++++++ force index
WITH amount AS (
	SELECT current_year, episode_number, COUNT(*) Amount_of_Equipment
	FROM cooks_recipes_per_episode
	JOIN uses_equipment USING (rec_name)
	GROUP BY current_year, episode_number) -- This subquery finds the amount of equipment for each episode.
SELECT current_year, episode_number, Amount_of_Equipment
FROM amount
WHERE Amount_of_Equipment= (
	SELECT MAX(Amount_of_Equipment)
	FROM amount
    ) -- This subquery finds the max amount of equipment an episode any had.
    -- The overall query could find more than 1 episode in case of a draw. 
    -- (More than 1 episode could have the max amount of equipment)
    ;

-- 3.9
SELECT current_year, AVG(grams_of_carbohydrates) 'Avarage Grams of Carbohydrates per Year'
FROM(
	SELECT current_year, grams_of_carbohydrates_per_portion*portions grams_of_carbohydrates
	FROM cooks_recipes_per_episode
	JOIN recipe USING (rec_name)) carbohydrates_of_each_recipe
GROUP BY current_year;

-- 3.10
-- Store the number of apps of each national cuisine for each year.
-- If a cuisine does not appear in a year, then number of apps will be null.
CREATE TEMPORARY TABLE nat_cus_year_apps
SELECT DISTINCT current_year, national_cuisine, Number_of_apps
FROM episodes_per_year
JOIN (
	SELECT DISTINCT national_cuisine
	FROM cooks_recipes_per_episode
	JOIN recipe USING(rec_name)
) nat_cus_appearing -- creates a table with every possible combination (year,national cuisine that has ever appeared).
LEFT JOIN (
	SELECT current_year, national_cuisine, COUNT(rec_name) Number_of_apps
	FROM(
		SELECT current_year, rec_name, national_cuisine
		FROM cooks_recipes_per_episode
		JOIN recipe USING(rec_name)
	) nat_cus_rec_per_year
	GROUP BY current_year, national_cuisine
) apps_of_nat_cus_per_year USING (current_year, national_cuisine) -- This subquery finds the cuisines that appear each year
																	-- and their apps that year.
;


-- Exclude national cuisines that do not appear at least 3 times each year.
CREATE TEMPORARY TABLE nat_cus_min_3apps_per_year
SELECT current_year, national_cuisine, Number_of_apps
FROM nat_cus_year_apps
WHERE national_cuisine NOT IN (SELECT DISTINCT national_cuisine
								FROM nat_cus_year_apps
								WHERE Number_of_apps IS NULL OR Number_of_apps <3
                                ) -- This subquery finds the national cuisines that appeared less than 3 times at least 1 year.
;


-- Find the amount of apps across 2 years of the remaining national cuisines.
CREATE TEMPORARY TABLE nat_cus_apps_per_2years
SELECT a.current_year first_year, b.current_year second_year, a.national_cuisine, a.Number_of_apps+b.Number_of_apps Number_of_apps
FROM nat_cus_min_3apps_per_year a
JOIN nat_cus_min_3apps_per_year b ON a.current_year = b.current_year-1 AND a.national_cuisine = b.national_cuisine
;

-- Keep only the cuisines that have the same amount of apps with other cuisines across two years.
SELECT DISTINCT a.first_year first_year, a.second_year second_year, 
				a.national_cuisine national_cuisine, a.Number_of_apps Number_of_apps
FROM nat_cus_apps_per_2years a
JOIN nat_cus_apps_per_2years b ON a.first_year=b.first_year AND a.national_cuisine != b.national_cuisine AND a.Number_of_apps = b.Number_of_apps 
ORDER BY first_year, Number_of_apps
;

DROP TABLE nat_cus_year_apps;
DROP TABLE nat_cus_min_3apps_per_year;
DROP TABLE nat_cus_apps_per_2years;

-- 3.11
-- Find all possible couples (judge,contestant) with their respective avarage grade and choose top 5. 
SELECT CONCAT(judge.name_of_cook,' ',judge.surname_of_cook) Judge_name,
		CONCAT(cont.name_of_cook,' ',cont.surname_of_cook) Contestant_name, 
		AVG(grade) Avarage_grade
FROM evaluation
JOIN cooks cont ON cont.cook_id=contestant_id
JOIN cooks judge ON judge.cook_id=judge_id
GROUP BY Contestant_name, Judge_name
ORDER BY Avarage_grade DESC
LIMIT 5;


-- 3.12
WITH avg_level_per_episode AS (
	SELECT current_year, episode_number, AVG(level_of_diff) avg_level
	FROM(
		SELECT current_year, episode_number, level_of_diff 
		FROM cooks_recipes_per_episode
		JOIN recipe USING(rec_name)
	) a
	GROUP BY current_year, episode_number
) -- This subquery finds the avarage level of difficulty of each episode.
SELECT current_year, episode_number, avg_level
FROM avg_level_per_episode c
WHERE avg_level = (
	SELECT MAX(avg_level)
    FROM avg_level_per_episode d
    GROUP BY current_year
    HAVING d.current_year=c.current_year
) -- This subquery finds the max avarage level of difficulty any episode had for a given year (c.current_year)
;


-- 3.13
-- Δίνουμε βαρύτητα:
-- 1 στον Γ Μάγειρα
-- 2 στον Β Μάγειρα
-- 3 στον Α Μάγειρα
-- 4 στον Βοηθό Σεφ
-- 5 στον Σεφ
WITH level_of_eps AS (
	SELECT current_year, episode_number, SUM(level_of_cook) level_of_episode
	FROM(
		SELECT current_year, episode_number, level_of_cook
		FROM(
			SELECT current_year, episode_number, cook_category
			FROM cooks_recipes_per_episode
			JOIN cooks USING (cook_id)
			UNION ALL
			SELECT current_year, episode_number, cook_category
			FROM judges
			JOIN cooks USING (cook_id)
		) cooks_categories -- This subquery finds the cook categories each episode contains (both judges and contestants)
		JOIN(
			SELECT 1 level_of_cook, 'C Cook' cook_category
			UNION
			SELECT 2 level_of_cook, 'B Cook' cook_category
			UNION
			SELECT 3 level_of_cook, 'A Cook' cook_category
			UNION
			SELECT 4 level_of_cook, "Chef's Assistant" cook_category
			UNION
			SELECT 5 level_of_cook, 'Chef' cook_category
		) temp USING (cook_category) -- this subquery maps each cook category to an integer representing the level of the cook.
	) temp1
	GROUP BY current_year, episode_number
) -- This subquery finds the level of each episode.
SELECT current_year, episode_number, level_of_episode
FROM level_of_eps
WHERE level_of_episode = (SELECT MIN(level_of_episode) FROM level_of_eps)
-- Total query might return more than 1 episode in case of a draw. 
;


-- 3.14
-- Αν μία θεματική ενότητα εμφανίζεται πάνω από 1 φορές στο ίδιο επεισόδιο, τότε θεωρούμε ότι εμφανίζεται πάνω από 1 φορά.
-- Αν δεν το θέλαμε αυτό θα μπορούσαμε να βάλουμε distinct στο subquery thematic_units_of_each_episode
WITH appearances AS (
	SELECT name_of_thematic_unit, COUNT(*) apps_num
	FROM(
		SELECT current_year, episode_number, name_of_thematic_unit
		FROM cooks_recipes_per_episode
		JOIN belongs_to_thematic_unit USING (rec_name)
	) thematic_units_of_each_episode
	GROUP BY name_of_thematic_unit
)-- this subquery finds the amount of appearances of each thematic unit.
SELECT name_of_thematic_unit, apps_num Number_of_Appearances
FROM appearances
WHERE apps_num = (SELECT MAX(apps_num) FROM appearances)
-- Total query might return more than 1 thematic unit in case of a draw. 
;



-- 3.15
SELECT name_of_food_group
FROM food_group
WHERE name_of_food_group NOT IN(
	SELECT name_of_food_group
	FROM cooks_recipes_per_episode
	JOIN recipe USING (rec_name)
	JOIN ingredients ON name_of_main_ingredient=name_of_ingredient
	JOIN food_group USING (name_of_food_group)
);

/*

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


CREATE TABLE recipe(
rec_name varchar(50), 
rec_type varchar(50) DEFAULT 'Regular' CHECK(rec_type IN ('Pastry','Regular')),
level_of_diff INT(11) CHECK (level_of_diff IN (1,2,3,4,5)),
short_descr VARCHAR(50)  DEFAULT NULL,
prep_time INT(11) CHECK (prep_time>0),
cooking_time INT(11) CHECK (cooking_time>0),
portions INT(11) CHECK (portions>0),
name_of_main_ingredient VARCHAR(50) NOT NULL,
grams_of_fat_per_portion INT(11) CHECK(grams_of_fat_per_portion>0),
grams_of_carbohydrates_per_portion INT(11) CHECK(grams_of_carbohydrates_per_portion>0),
grams_of_proteins_per_portion INT(11) CHECK(grams_of_proteins_per_portion>0),
calories_per_portion INT(11),
national_cuisine VARCHAR(50), 
PRIMARY KEY (rec_name)
);

INSERT INTO recipe
VALUES ('Paidakia',DEFAULT,3,'cooked children',15,45,4,'Meat',300,100,250,380,'Greek'),
		('Rice',DEFAULT,1,'rice',5,30,3,'rice',50,300,20,80,'Greek'),
        ('Ice Cream','Pastry',3,'2 Chocolate Ice Cream Balls',15,20,2,'Chocolate',100,50,10,180,'French'),
        ('Chicken Soup',DEFAULT,3,NULL,25,45,1,'Chicken',200,150,150,250,'Greek'),
        ('Joe Dada',DEFAULT,5,'cooked dada',60,45,1,'Murdered Dada',500,300,450,680,'German'),
        ('Cookies',DEFAULT,4,NULL,25,25,10,'Chocolate',200,100,250,280,'German');

CREATE TABLE food_group(
name_of_food_group VARCHAR(50),
description_of_food_group VARCHAR(50),
recipe_description VARCHAR(50),
PRIMARY KEY (name_of_food_group)
);

INSERT INTO food_group
VALUES ('Pasta',NULL,NULL),
		('Sweet',NULL,NULL),
        ('Protein food',NULL,NULL),
        ('People',NULL,NULL),
        ('Fish',NULL,NULL),
        ('Legumes',NULL,NULL);

CREATE TABLE ingredients(
name_of_ingredient VARCHAR(50),
calories_per_100gr INT(11),
name_of_food_group VARCHAR(50) NOT NULL,
PRIMARY KEY (name_of_ingredient)
);

INSERT INTO ingredients
VALUES ('Meat',200,'Protein food'),
		('rice',100,'Pasta'),
        ('Chocolate',120,'Sweet'),
        ('Chicken',180,'Protein food'),
        ('Murdered Dada',300,'People');

CREATE TABLE thematic_unit(
name_of_thematic_unit VARCHAR(50),
description_of_thematic_unit VARCHAR(100),
PRIMARY KEY (name_of_thematic_unit)
);

INSERT INTO thematic_unit
VALUES ('Barbeque food',NULL),
		('Chinese food', NULL),
        ('Food to eat when sick', NULL),
        ('Food for dessert', NULL),
        ('Food for crying', NULL),
        ('Food to get fat', NULL),
        ('Food for cannibals', NULL),
        ('Food for murderes', NULL);

CREATE TABLE belongs_to_thematic_unit(
rec_name VARCHAR(50),
name_of_thematic_unit VARCHAR(50),
PRIMARY KEY (rec_name,name_of_thematic_unit)
);

INSERT INTO belongs_to_thematic_unit
VALUES ('Paidakia','Barbeque food'),
		('Rice','Chinese food'),
        ('Rice','Food to eat when sick'),
        ('Ice Cream','Food for dessert'),
        ('Ice Cream','Food for crying'),
        ('Ice Cream','Food to get fat'),
        ('Chicken Soup','Food to eat when sick'),
        ('Joe Dada','Food for cannibals'),
        ('Joe Dada','Food for murderes'),
        ('Cookies','Food to get fat'),
        ('Cookies','Food for dessert');
        
CREATE TABLE uses_equipment(
rec_name VARCHAR(50),
equipment_name VARCHAR(50),
PRIMARY KEY (rec_name,equipment_name)
);

INSERT INTO uses_equipment
VALUES ('Paidakia','Barbeque'),
		('Rice','Pot'),
        ('Ice Cream','Mixer'),
        ('Chicken Soup','Pot'),
        ('Joe Dada','Knife'),
        ('Joe Dada','Gun'),
        ('Joe Dada','Rope'),
        ('Joe Dada','Barbeque'),
        ('Cookies','Oven'),
        ('Cookies','Mixer');
        
CREATE TABLE tags(
tag_name VARCHAR(50),
rec_name VARCHAR(50),
PRIMARY KEY(tag_name,rec_name)
);

INSERT INTO tags
VALUES ('Lunch','Paidakia'),
		('Ideal for Easter','Paidakia'),
        ('Barbeque dish','Paidakia'),
        ('Test','Paidakia'),
		('Chinese dish','Rice'),
        ('Lunch','Rice'),
        ('Dinner','Rice'),
        ('Test','Rice'),
        ('Sweet dish','Ice Cream'),
        ('Ideal for Parties','Ice Cream'),
        ('Ideal for Sad Moments','Ice Cream'),
        ('Lunch','Chicken Soup'),
        ('Inferior dish','Chicken Soup'),
        ('Lunch','Joe Dada'),
        ('Dinner','Joe Dada'),
        ('Test','Joe Dada'),
        ('Crazy dish','Joe Dada'),
        ('Ideal for Parties','Joe Dada'),
        ('Cold','Cookies'),
        ('Ideal for Parties','Cookies'),
        ('Sweet dish','Cookies');
        

CREATE TABLE tips(
rec_name VARCHAR(50),
tip VARCHAR(50),
PRIMARY KEY (rec_name,tip)
);

INSERT INTO tips
VALUES ('Rice','abc'),
		('Rice','def'),
        ('Rice','ghi');


CREATE TABLE needs_ingredient(
name_of_ingredient VARCHAR(50),
rec_name VARCHAR(50),
quantity VARCHAR(50),
PRIMARY KEY (name_of_ingredient,rec_name)
);




        


    
     

                        


-- 3.6
create index tag
on tags (tag_name);

SELECT a_tag_name, b_tag_name, COUNT(*) Tag_Couple_Appearances
FROM(
SELECT current_year, episode_number, competition.rec_name recipe, a.tag_name a_tag_name, b.tag_name b_tag_name
FROM cooks_recipes_per_episode competition
JOIN tags a IGNORE INDEX (tag_name) USING (rec_name) 
JOIN tags b ON a.rec_name=b.rec_name AND a.tag_name<b.tag_name
ORDER BY current_year, episode_number, competition.rec_name
) temp1
GROUP BY a_tag_name, b_tag_name;

alter table tags
drop index tag;


-- 3.8
WITH amount AS (
	SELECT current_year, episode_number, COUNT(*) Amount_of_Equipment
	FROM cooks_recipes_per_episode
	JOIN uses_equipment USING (rec_name)
	GROUP BY current_year, episode_number)
SELECT current_year, episode_number, Amount_of_Equipment
FROM amount
WHERE Amount_of_Equipment= (
	SELECT MAX(Amount_of_Equipment)
	FROM amount
    );




-- 3.10
INSERT INTO episodes_per_year
VALUES(2002,1);

INSERT INTO recipe
VALUES ('something1',DEFAULT,1,NULL,34,34,4,'FCSD',23,23,23,12,'Brasilian'),
		('something2',DEFAULT,1,NULL,34,34,4,'FCSD',23,23,23,12,'Brasilian'),
        ('something3',DEFAULT,1,NULL,34,34,4,'FCSD',23,23,23,12,'Brasilian'),
        ('somethingelse1',DEFAULT,1,NULL,34,34,4,'FCSD',23,23,23,12,'Argentinian'),
		('somethingelse2',DEFAULT,1,NULL,34,34,4,'FCSD',23,23,23,12,'Argentinian'),
        ('somethingelse3',DEFAULT,1,NULL,34,34,4,'FCSD',23,23,23,12,'Argentinian');

INSERT INTO cooks_recipes_per_episode
VALUES (2000,1,'something1',20),
		(2000,1,'something2',21),
        (2000,1,'something3',22),
        (2001,1,'something1',20),
        (2001,2,'something2',21),
        (2001,3,'something3',22),
        (2002,1,'something1',20),
		(2002,1,'something2',21),
        (2002,1,'something3',22),
        (2000,1,'somethingelse1',30),
		(2000,1,'somethingelse2',31),
        (2000,1,'somethingelse3',32),
        (2001,1,'somethingelse1',30),
        (2001,2,'somethingelse2',31),
        (2001,3,'somethingelse3',32),
        (2002,1,'somethingelse1',30),
		(2002,1,'somethingelse2',31),
        (2002,1,'somethingelse3',32);

DELETE FROM recipe
WHERE national_cuisine IN ('Brasilian','Argentinian');

DELETE FROM episodes_per_year
WHERE current_year=2002;

DELETE FROM cooks_recipes_per_episode
WHERE rec_name IN ('something1','something2','something3','somethingelse1','somethingelse2','somethingelse3');



