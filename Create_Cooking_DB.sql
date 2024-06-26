DROP DATABASE IF EXISTS `cooking`;
CREATE DATABASE `cooking`; 
USE `cooking`;

CREATE TABLE food_group(
name_of_food_group VARCHAR(50),
description_of_food_group VARCHAR(50),
recipe_description VARCHAR(50) NOT NULL,
image_of_food_group VARCHAR(50),
image_of_food_group_desc VARCHAR(100),
PRIMARY KEY (name_of_food_group)
);

CREATE TABLE ingredients(
name_of_ingredient VARCHAR(50),
calories_per_100gr INT(11) NOT NULL,
name_of_food_group VARCHAR(50) NOT NULL,
image_of_ingredient VARCHAR(50),
image_of_ingredient_desc VARCHAR(100),
PRIMARY KEY (name_of_ingredient),
CONSTRAINT f_key_ingredients_food_group FOREIGN KEY (name_of_food_group) REFERENCES food_group (name_of_food_group)
);

CREATE TABLE needs_ingredient(
name_of_ingredient VARCHAR(50),
rec_name VARCHAR(50),
quantity VARCHAR(50) NOT NULL,
PRIMARY KEY (name_of_ingredient,rec_name),
CONSTRAINT f_key_needs_ingredient_ingredients FOREIGN KEY (name_of_ingredient) REFERENCES ingredients (name_of_ingredient)
);

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
national_cuisine VARCHAR(50) NOT NULL,
image_of_recipe VARCHAR(50),
image_of_recipe_desc VARCHAR(100), 
PRIMARY KEY (rec_name),
CONSTRAINT f_key_recipe_ingredients FOREIGN KEY (name_of_main_ingredient,rec_name) REFERENCES needs_ingredient (name_of_ingredient,rec_name)
);



CREATE TABLE type_of_meal(
meal_type VARCHAR(50) DEFAULT 'Lunch',
rec_name VARCHAR(50),
PRIMARY KEY(meal_type,rec_name),
CONSTRAINT f_key_meal_recipe FOREIGN KEY (rec_name) REFERENCES recipe (rec_name)
);

CREATE TABLE tags(
tag_name VARCHAR(50),
rec_name VARCHAR(50),
PRIMARY KEY(tag_name,rec_name),
CONSTRAINT f_key_tags_recipe FOREIGN KEY (rec_name) REFERENCES recipe (rec_name)
);

CREATE TABLE tips(
rec_name VARCHAR(50),
tip VARCHAR(90),
PRIMARY KEY (rec_name,tip),
CONSTRAINT f_key_tips_recipe FOREIGN KEY (rec_name) REFERENCES recipe (rec_name)
);


CREATE TABLE equipment(
equipment_name VARCHAR(50),
instruction_manual VARCHAR(200),
image_of_equipment VARCHAR(50),
image_of_equipment_desc VARCHAR(100),
PRIMARY KEY(equipment_name)
);

CREATE TABLE uses_equipment(
rec_name VARCHAR(50),
equipment_name VARCHAR(50),
PRIMARY KEY (rec_name,equipment_name),
CONSTRAINT f_key_uses_equipment_recipe FOREIGN KEY (rec_name) REFERENCES recipe (rec_name),
CONSTRAINT f_key_uses_equipment_equipment FOREIGN KEY (equipment_name) REFERENCES equipment (equipment_name)
);

CREATE TABLE step(
instructions VARCHAR(100),
step_num INT(11),
rec_name VARCHAR(50),
PRIMARY KEY (step_num,rec_name),
CONSTRAINT f_key_step_recipe FOREIGN KEY (rec_name) REFERENCES recipe (rec_name)
);

CREATE TABLE thematic_unit(
name_of_thematic_unit VARCHAR(50),
description_of_thematic_unit VARCHAR(100),
image_of_thematic_unit VARCHAR(50),
image_of_thematic_unit_desc VARCHAR(100),
PRIMARY KEY (name_of_thematic_unit)
);

CREATE TABLE belongs_to_thematic_unit(
rec_name VARCHAR(50),
name_of_thematic_unit VARCHAR(50),
PRIMARY KEY (rec_name,name_of_thematic_unit),
CONSTRAINT f_key_belongs_to_thematic_unit_recipe FOREIGN KEY (rec_name) REFERENCES recipe (rec_name),
CONSTRAINT f_key_belongs_to_thematic_unit_thematic_unit FOREIGN KEY (name_of_thematic_unit) REFERENCES thematic_unit (name_of_thematic_unit)
);

CREATE TABLE cooks(
cook_id INT(11),
name_of_cook VARCHAR(50) NOT NULL,
surname_of_cook VARCHAR(50) NOT NULL,
phone_number VARCHAR(50),
date_of_birth date NOT NULL,
age INT(11),
years_of_experience INT(11) CHECK(years_of_experience>0),
cook_category VARCHAR(50) CHECK(cook_category IN ('C Cook', 'B Cook', 'A Cook', 'Chef', "Chef's Assistant")),
image_of_cook VARCHAR(50),
image_of_cook_desc VARCHAR(100),
PRIMARY KEY (cook_id)
);

CREATE TABLE cooks_belongs_to_national_cuisine(
cook_id INT(11) ,
type_of_national_cuisine_that_belongs_to VARCHAR(50),
PRIMARY KEY (cook_id,type_of_national_cuisine_that_belongs_to),
CONSTRAINT f_key_cooks_belongs_to_national_cuisine_cooks FOREIGN KEY (cook_id) REFERENCES cooks(cook_id) 
);

CREATE TABLE episodes_per_year(
current_year INT(11),
episode_number INT(11) CHECK(episode_number<=10 AND episode_number>0),
image_of_episode VARCHAR(50) DEFAULT NULL,
image_of_episode_desc VARCHAR(100) DEFAULT NULL,
PRIMARY KEY(current_year,episode_number)
);

CREATE TABLE cooks_recipes_per_episode(
current_year INT(11) ,
episode_number INT(11) ,
rec_name VARCHAR(50) NOT NULL,
cook_id INT(11),
PRIMARY KEY (current_year,episode_number,cook_id),
CONSTRAINT f_key_cooks_recipes_per_episode_cooks FOREIGN KEY (cook_id) REFERENCES cooks(cook_id), 
CONSTRAINT f_key_cooks_recipes_per_episode_recipe FOREIGN KEY (rec_name) REFERENCES recipe(rec_name), 
CONSTRAINT f_key_cooks_recipes_per_episode_episodes_per_year FOREIGN KEY (current_year,episode_number) REFERENCES episodes_per_year(current_year,episode_number)
); 

CREATE TABLE evaluation(
current_year INT(11) ,
episode_number INT(11) ,
contestant_id INT(11) ,
judge_id INT(11) , 
grade INT(11) CHECK (grade IN (1,2,3,4,5)),
PRIMARY KEY (current_year,episode_number,contestant_id,judge_id),
CONSTRAINT f_key_evaluation_episodes_per_year FOREIGN KEY (current_year,episode_number) REFERENCES episodes_per_year(current_year,episode_number),
CONSTRAINT f_key_evaluation_cooks_contestant FOREIGN KEY (contestant_id) REFERENCES cooks(cook_id),
CONSTRAINT f_key_evaluation_cooks_judge FOREIGN KEY (judge_id) REFERENCES cooks(cook_id),
CONSTRAINT f_key_evaluation_cooks_recipes_per_episode FOREIGN KEY (current_year,episode_number,contestant_id) REFERENCES cooks_recipes_per_episode(current_year,episode_number,cook_id)
);

CREATE TABLE winners(
current_year INT(11) ,
episode_number INT(11) ,
cook_id INT(11) ,
PRIMARY KEY (current_year,episode_number,cook_id),
CONSTRAINT f_key_winners_episodes_per_year FOREIGN KEY (current_year,episode_number) REFERENCES episodes_per_year(current_year,episode_number),
CONSTRAINT f_key_winners_cooks_recipes_per_episode FOREIGN KEY (current_year,episode_number,cook_id) REFERENCES cooks_recipes_per_episode(current_year,episode_number,cook_id),
CONSTRAINT f_key_winners_cooks FOREIGN KEY (cook_id) REFERENCES cooks(cook_id)
);

CREATE TABLE cook_credentials(
cook_id INT(11),
cook_username VARCHAR(20) NOT NULL,
cook_password VARCHAR(50) NOT NULL,
PRIMARY KEY (cook_id),
CONSTRAINT f_key_cook_credentials_cooks FOREIGN KEY (cook_id) REFERENCES cooks(cook_id)
);





-- Triggers

DELIMITER //
CREATE TRIGGER calculates_age_on_insert BEFORE INSERT ON cooks
FOR EACH ROW
BEGIN

SET NEW.age =  TIMESTAMPDIFF(YEAR,NEW.date_of_birth,CURDATE()); 

END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER if_age_needs_to_be_changed BEFORE UPDATE ON cooks
FOR EACH ROW 
BEGIN

IF NEW.date_of_birth != OLD.date_of_birth THEN
SET NEW.age = TIMESTAMPDIFF(YEAR,NEW.date_of_birth,CURDATE()); 
END IF; 

END;
//
DELIMITER ; 



DELIMITER //
CREATE TRIGGER prevents_more_than_3_tips BEFORE INSERT ON tips 
FOR EACH ROW
BEGIN

IF (SELECT COUNT(*) FROM tips WHERE New.rec_name = rec_name) = 3 
THEN SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'ALREADY 3 TIPS';
END IF; 

END;
//
DELIMITER ;


DELIMITER // 
CREATE TRIGGER calculate_calories_for_recipe_on_insert_recipe BEFORE INSERT ON recipe
FOR EACH ROW
BEGIN

SET NEW.calories_per_portion = (
	SELECT SUM(val)
    FROM(
		SELECT calories_per_100gr*quantity/100/NEW.portions val
		FROM ingredients 
        JOIN needs_ingredient USING (name_of_ingredient)
		WHERE NEW.rec_name = rec_name
        ) temporary
);

END;
//
DELIMITER ;

DELIMITER // 
CREATE TRIGGER calculate_calories_for_recipe_on_insert_needs_ingredient AFTER INSERT ON needs_ingredient
FOR EACH ROW
BEGIN

UPDATE recipe
SET calories_per_portion = calories_per_portion + (
	SELECT calories_per_100gr*NEW.quantity/100/portions 
    FROM ingredients 
    WHERE name_of_ingredient = NEW.name_of_ingredient)
WHERE rec_name = NEW.rec_name;

END;
//
DELIMITER ;



DELIMITER //
CREATE TRIGGER common_national_cuisine BEFORE INSERT ON cooks_recipes_per_episode
FOR EACH ROW
BEGIN

IF (SELECT national_cuisine
	FROM recipe 
    WHERE rec_name=NEW.rec_name AND national_cuisine IN (
				SELECT type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine WHERE cook_id=NEW.cook_id
                ) IS NULL)
THEN SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Cook and recipe do not have a common national cuisine';
END IF; 

END;
//
DELIMITER ;
 
DELIMITER //
CREATE TRIGGER duplicate_national_cuisine BEFORE INSERT ON cooks_recipes_per_episode
FOR EACH ROW
BEGIN

IF (SELECT national_cuisine
	FROM recipe 
    WHERE rec_name=NEW.rec_name AND national_cuisine IN (
				SELECT national_cuisine FROM recipe WHERE rec_name=NEW.rec_name
                ) IS NOT NULL)
THEN SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Duplicate national cuisine';
END IF; 

END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER more_than_10_cooks_recipes BEFORE INSERT ON cooks_recipes_per_episode
FOR EACH ROW
BEGIN

IF (SELECT COUNT(*)
	FROM cooks_recipes_per_episode
    WHERE current_year=NEW.current_year AND episode_number=NEW.episode_number
    )=10
THEN SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Exceeded maximum amount of cooks and recipes per episode';
END IF; 

END;
//
DELIMITER ;




-- Indexes

CREATE INDEX national_cuisine_idx ON recipe(national_cuisine);
CREATE INDEX cook_category_idx ON cooks (cook_category);
