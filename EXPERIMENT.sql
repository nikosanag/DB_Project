SET SQL_SAFE_UPDATES = 0; 

DELIMITER // 
CREATE PROCEDURE build_contest(IN starting_year INT(11),IN ending_year INT(11))
BEGIN
DECLARE count_years INT(11);
DECLARE count_episodes INT(11);
DECLARE count_places INT(11);
DECLARE cook_id_to_enter INT(11);
DECLARE national_cuisine_to_enter VARCHAR (50);
DECLARE rec_name_to_enter VARCHAR(50); 

DELETE FROM winners;
DELETE FROM evaluation;
DELETE FROM judges;
DELETE FROM cooks_recipes_per_episode;
DELETE FROM episodes_per_year;

CREATE TABLE possible_num(
num INT(11),
PRIMARY KEY(num)
);

INSERT INTO possible_num(num) VALUE (1),(2),(3),(4),(5);

CREATE TABLE cooks_recipes_per_episode_(
current_year INT(11) ,
episode_number INT(11) ,
national_cuisine VARCHAR(50),
rec_name VARCHAR(50),
cook_id INT(11),
PRIMARY KEY (current_year,episode_number,national_cuisine) 
); 

CREATE TABLE security_purposes_cooks(
	cook_id INT(11),
	triggering_number INT(11),
	PRIMARY KEY (cook_id)
);
/*
CREATE TABLE security_purposes_recipes(
rec_name VARCHAR(50),
triggering_number INT(11),
PRIMARY KEY(rec_name)
);
*/
CREATE TABLE security_purposes_national_cuisine(
name_national VARCHAR(50),
triggering_number INT(11),
PRIMARY KEY(name_national)
);

CREATE TABLE available_cooks (
	cook_id INT(11),
	national_cuisine VARCHAR(50),
	PRIMARY KEY(cook_id,national_cuisine)
);

CREATE TABLE available_recipes(
	rec_name VARCHAR(50),
	national_cuisine VARCHAR(50), 
	PRIMARY KEY(rec_name)
);

CREATE TABLE available_national_cuisines(
national_cuisine VARCHAR(50),
PRIMARY KEY (national_cuisine)
);

INSERT INTO security_purposes_cooks(cook_id,triggering_number) 
SELECT  cook_id,0 FROM cooks ;

/*
INSERT INTO security_purposes_recipes(rec_name,triggering_number)
SELECT DISTINCT rec_name,0 FROM recipe;
*/

INSERT INTO security_purposes_national_cuisine(name_national,triggering_number)
SELECT DISTINCT type_of_national_cuisine_that_belongs_to,0 FROM cooks_belongs_to_national_cuisine;

SET count_years = starting_year ;
INSERT INTO available_recipes(rec_name,national_cuisine) 
SELECT DISTINCT rec_name,national_cuisine FROM recipe 
ORDER BY RAND();
			
            WHILE (count_years <= ending_year) DO
				BEGIN
						SET count_episodes = 1;
                        WHILE (count_episodes <= 10) DO
									BEGIN    
											
											SET count_places = 1;
											
                                            INSERT INTO episodes_per_year(current_year,episode_number) VALUE (count_years,count_episodes) ; 
                                            
                                            INSERT INTO available_cooks(cook_id,national_cuisine) 
                                            SELECT  cook_id,type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine 
                                            ORDER BY RAND(); 
                                            
                                          
                                            
                                            INSERT INTO available_national_cuisines(national_cuisine) 
                                            SELECT  DISTINCT type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine 
                                            ORDER BY RAND();
                                            
                                            WHILE (count_places<=10) DO 
													BEGIN
                                                    
                                                    SET national_cuisine_to_enter = 
                                                    (
                                                    SELECT national_cuisine FROM available_national_cuisines 
                                                    WHERE national_cuisine IN 
                                                    (SELECT name_national FROM security_purposes_national_cuisine WHERE triggering_number<3)
                                                    ORDER BY RAND()
                                                    LIMIT 1 
                                                    );
                                                    
                                                    UPDATE security_purposes_national_cuisine SET triggering_number = triggering_number+1 
                                                    WHERE name_national = national_cuisine_to_enter ;
                                                    
                                                    DELETE FROM available_national_cuisines WHERE national_cuisine = national_cuisine_to_enter;
                                                    
											        SET cook_id_to_enter = 
                                                    (
                                                    SELECT cook_id FROM available_cooks WHERE (cook_id IN (SELECT cook_id FROM security_purposes_national_cuisine WHERE triggering_number<3)) 
													AND ((cook_id,national_cuisine_to_enter) IN (SELECT cook_id,national_cuisine FROM available_cooks))
                                                    ORDER BY RAND()
                                                    LIMIT 1
                                                    );
                                                    
                                                    UPDATE security_purposes_cooks SET triggering_number = triggering_number + 1 WHERE cook_id = cook_id_to_enter;
                                                    
                                                    DELETE FROM available_cooks WHERE cook_id = cook_id_to_enter; 
                                                    
                                                    SET rec_name_to_enter = 
                                                    (
                                                    SELECT rec_name FROM available_recipes 
                                                    WHERE national_cuisine = national_cuisine_to_enter 
                                                    ORDER BY RAND()
                                                    LIMIT 1
                                                    );
                                                    
                                                    INSERT INTO cooks_recipes_per_episode_(current_year,episode_number,national_cuisine,rec_name,cook_id) 
                                                    VALUE (count_years,count_episodes,national_cuisine_to_enter,rec_name_to_enter,cook_id_to_enter);
                                                    
                                                    SET count_places = count_places + 1; 
                                                    END;
                                                    END WHILE; 
                                                    
                                                    
											INSERT INTO judges(current_year,episode_number,cook_id) SELECT DISTINCT count_years,count_episodes,cook_id FROM available_cooks WHERE (cook_id IN (SELECT cook_id FROM security_purposes_cooks WHERE triggering_number<3)) ORDER BY RAND() LIMIT 3;
                                            UPDATE security_purposes_cooks SET triggering_number = triggering_number + 1 WHERE cook_id IN (SELECT cook_id FROM judges WHERE current_year = count_years AND episode_number = count_episodes); 
                                            DELETE FROM available_cooks WHERE cook_id IN (SELECT cook_id FROM judges WHERE current_year = count_years AND episode_number = count_episodes);
                                            
                                            INSERT INTO evaluation(current_year,episode_number,contestant_id,judge_id,grade)
                                            SELECT count_years,count_episodes, crpe.cook_id, j.cook_id,
                                            (SELECT num FROM possible_num ORDER BY RAND() LIMIT 1) 
                                            FROM cooks_recipes_per_episode_ crpe							
                                            JOIN
                                            judges j ON crpe.current_year = j.current_year AND j.episode_number = crpe.episode_number
                                            WHERE 
                                            crpe.current_year = count_years
                                            AND crpe.episode_number = count_episodes
                                            ;
                                            
											INSERT INTO winners
                                            SELECT count_years,count_episodes,cook_id,SUM(grade) avg_grade, cook_category
                                            FROM (
                                            SELECT contestant_id AS cook_id,grade
                                            FROM evaluation
                                            WHERE current_year= count_years AND episode_number = count_episodes) temp
                                            JOIN cooks USING (cook_id)
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
												) tempo USING (cook_category)
                                            GROUP BY cook_id
                                            ORDER BY avg_grade,level_of_cook,RAND()
                                            LIMIT 1
                                            ;
                                            
                                            
											UPDATE security_purposes_cooks SET triggering_number = 0 WHERE (cook_id IN (SELECT cook_id FROM available_cooks));
                                            UPDATE security_purposes_national_cuisine SET triggering_number = 0 WHERE (name_national IN (SELECT national_cuisine FROM available_national_cuisines));
                                            DELETE FROM available_cooks;
                                            DELETE FROM available_national_cuisines;
                                            /*DELETE FROM available_recipes;*/
											SET count_episodes = count_episodes + 1;
                                    END;
                                    END WHILE;
                        
						SET count_years = count_years+1;
				END;
				END WHILE;

INSERT INTO cooks_recipes_per_episode(current_year,episode_number,rec_name,cook_id) SELECT current_year,episode_number,rec_name,cook_id FROM cooks_recipes_per_episode_;

/*DROP TABLE cooks_recipes_per_episode_;*/
DROP TABLE possible_num;
DROP TABLE  security_purposes_cooks;
/*DROP TABLE security_purposes_recipes;*/
DROP TABLE security_purposes_national_cuisine;
DROP TABLE available_national_cuisines;
DROP TABLE available_recipes;
DROP TABLE available_cooks;
END;
//
DELIMITER ;

CALL build_contest(2020,2024);