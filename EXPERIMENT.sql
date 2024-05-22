/*useful so i can delete anything from a table*/ 
SET SQL_SAFE_UPDATES = 0; 


CREATE TABLE cooks_recipes_per_episode_(
current_year INT(11) ,
episode_number INT(11) ,
national_cuisine VARCHAR(11),
rec_name VARCHAR(50),
cook_id INT(11),
PRIMARY KEY (current_year,episode_number,national_cuisine) 
); 

CREATE TABLE security_purposes_cooks(
	cook_id INT(11),
	triggering_number INT(11),
	PRIMARY KEY (cook_id)
);

CREATE TABLE security_purposes_recipes(
rec_name VARCHAR(50),
triggering_number INT(11),
PRIMARY KEY(rec_name)
);

CREATE TABLE security_purposes_national_cuisine(
name_national VARCHAR(50),
triggering_number INT(11),
PRIMARY KEY(name_national)
);

CREATE TABLE available_cooks (
	cook_id INT(11),
	type_of_national_cuisine_that_belongs_to VARCHAR(50),
	PRIMARY KEY(cook_id,type_of_national_cuisine_that_belongs_to)
);

CREATE TABLE available_recipes(
	rec_name VARCHAR(50),
	national_cuisine VARCHAR(50), 
	PRIMARY KEY(rec_name,national_cuisine)
);

CREATE TABLE available_national_cuisines(
national_cuisine VARCHAR(50),
PRIMARY KEY (national_cuisine)
);

DELIMITER // 
CREATE PROCEDURE updating_security_check_cooks(IN cooker_id INT(11)) 
BEGIN    
	IF (SELECT COUNT(*) FROM security_purposes_cooks WHERE cooker_id = cook_id) = 0 /*isnt in table security_purposes*/
	THEN
		INSERT INTO security_purposes_cooks(cook_id,triggering_number) VALUE (cooker_id,1) ;
	
    ELSE 
		UPDATE security_purposes_cooks
        SET triggering_number = triggering_number + 1 
        WHERE cook_id = cooker_id; 
	END IF;
 
END;
// 
DELIMITER ; 

DELIMITER //
CREATE PROCEDURE updating_security_check_recipes(in rec_nam VARCHAR(50))
BEGIN
		IF (SELECT COUNT(*) FROM security_purposes_recipes WHERE rec_nam = rec_name) = 0 /*isnt in table security_purposes recipes*/
        THEN INSERT INTO security_purposes_recipes(rec_name,triggering_number) VALUE (rec_nam,1); 
        
        ELSE
			UPDATE security_purposes_recipes
            SET triggering_number = triggering_number + 1
            WHERE rec_nam = rec_name;
            END IF;
END; 
//
DELIMITER ; 

DELIMITER // 
CREATE PROCEDURE updating_security_check_national_cuisines(in name_of_national VARCHAR(50))
BEGIN
		IF (SELECT COUNT(*) FROM security_purposes_national_cuisine WHERE name_national = name_of_national) = 0 
        THEN INSERT INTO security_purposes_national_cuisine(name_national,triggering_number) VALUE (name_of_national,1);
        
        ELSE 
			UPDATE security_purposes_national_cuisine
            SET triggering_number = triggering_number + 1
            WHERE name_national = name_of_national;
		END IF;
END;
//
DELIMITER ;


/*SUPER IMPORTANT for inserting recipes and cooks...open on your own risk...I warned you!*/




/*initializes the procedure of making a single episode.*/
DELIMITER // 
CREATE PROCEDURE creation_of_episode(IN requested_year INT(11), requested_episode INT(11))
BEGIN
	INSERT INTO available_cooks(cook_id,type_of_national_cuisine_that_belongs_to) 
    SELECT  cook_id,type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine ORDER BY RAND() ; 
    INSERT INTO available_recipes(rec_name,national_cuisine) 
    SELECT  rec_name,national_cuisine FROM recipe ORDER BY RAND() ;


    
	INSERT INTO cooks_recipes_per_episode_ (current_year,episode_number,national_cuisine)
	SELECT requested_year,requested_episode,national_cuisine
	FROM available_national_cuisines
	ORDER BY RAND()	
	LIMIT 10; /*για καθε national cuisine που μπανει στον πινακα cooks_recipes_per_episode μεσα απο ενα trigger για αυτο το πινακα υλοποιειται η επιλογη μαγειρα και συνταγης!*/
  
	INSERT INTO judges (current_year,episode_number,cook_id)
	SELECT requested_year,requested_episode,cook_id
	FROM available_cooks
	ORDER BY RAND()	
	LIMIT 3;    
	
    
    DELETE FROM security_purposes_cooks WHERE cook_id = (SELECT DISTINCT cook_id FROM available_cooks);
    DELETE FROM available_cooks;
    DELETE FROM security_purposes_recipes WHERE rec_name = (SELECT DISTINCT rec_name FROM available_recipes);
    DELETE FROM available_recipes;
END;
//
DELIMITER ;




DELIMITER // 
CREATE PROCEDURE build_the_contest(IN starting_year INT(11),end_year INT(11)) 
BEGIN


DECLARE counta INT(11); 
DECLARE count_inside INT(11);
DECLARE count_help INT(11);
DECLARE nation VARCHAR(50);
DECLARE id INT(11);
DECLARE rname VARCHAR(50); 
DELETE FROM judges;
DELETE FROM evaluation;
DELETE FROM security_purposes_cooks;
DELETE FROM security_purposes_national_cuisine ; 
DELETE FROM security_purposes_recipes;
DELETE FROM episodes_per_year; 
SET counta = starting_year ; 

WHILE (counta < end_year+1) DO
	BEGIN
    SET count_inside = 1;    
    WHILE (count_inside <= 10) DO
		BEGIN
        INSERT INTO episodes_per_year(current_year,episode_number) VALUE (counta,count_inside);
		
        INSERT INTO available_cooks(cook_id,type_of_national_cuisine_that_belongs_to) 
		SELECT  cook_id,type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine ORDER BY RAND() ; 
		INSERT INTO available_recipes(rec_name,national_cuisine) 
		SELECT  rec_name,national_cuisine FROM recipe ORDER BY RAND() ;
        
        INSERT INTO available_national_cuisines
		SELECT DISTINCT type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine 
        WHERE 
        (((SELECT DISTINCT triggering_number FROM security_purposes_national_cuisine
        WHERE name_national=type_of_national_cuisine_that_belongs_to limit 1) < 3) 
        OR ((type_of_national_cuisine_that_belongs_to NOT IN (SELECT name_national FROM security_purposes_national_cuisine 
        ))));
        
        /*επιλεγει τους national cuisines που δεν εχουνε παρουσιαστει τρεις συνεχομενες φορε μοναχα*/
		SET count_help = 1;
        
        WHILE (count_help<=10) DO
        BEGIN
        /*αναζητα καταλληλο cook.Ο καταλληλος ειναι ενας που δεν ειναι ακομα στο security_purposes_cooks ή αν ειναι δεν ειναι το triggering number = 3...και ενας που ανηκει σε αυτη την εθνικη κουζινα*/
    SET nation = (select national_cuisine from available_national_cuisines ORDER BY rand() 
    LIMIT 1); 
    SET id = (
    SELECT cook_id FROM available_cooks WHERE ((((SELECT triggering_number FROM security_purposes_cooks where cook_id = security_purposes_cooks.cook_id) < 3) 
    OR (cook_id NOT IN (SELECT DISTINCT cook_id FROM security_purposes_cooks))) 
    AND (cook_id IN (SELECT DISTINCT cook_id FROM cooks_belongs_to_national_cuisine 
    WHERE (type_of_national_cuisine_that_belongs_to = nation))))
    LIMIT 1
    );
	
    

	DELETE FROM available_cooks 
    WHERE cook_id = id; 
   
  CALL updating_security_check_cooks(id); 
    
 
    SET rname = (SELECT rec_name FROM available_recipes 
    WHERE ((nation = national_cuisine) 
    AND ((SELECT triggering_number FROM security_purposes_recipes WHERE available_recipes.rec_name = security_purposes_recipes.rec_name)<3 
    OR (available_recipes.rec_name NOT IN (SELECT rec_name FROM security_purposes_recipes ))))
    LIMIT 1);
	
     
 
	DELETE FROM available_recipes
    WHERE rec_name = rname; 
    
 
    CALL updating_security_check_recipes(rname);
    
    
     
    DELETE FROM available_national_cuisines
    WHERE (national_cuisine = nation);
    
    
	CALL updating_security_check_national_cuisines(nation);
    
        SET count_help = count_help+1;
        INSERT INTO cooks_recipes_per_episode_ (current_year,episode_number,national_cuisine,rec_name,cook_id) VALUE (counta,count_inside,nation,rname,id);
        END;
        END WHILE;
        
        
        SET count_inside = count_inside+1;
        
        DELETE FROM available_national_cuisines; 
        DELETE FROM available_cooks;
        DELETE FROM available_recipes;
        END; 
        END WHILE;
        
	SET counta = counta + 1 ; 
	END; 
    END WHILE;


INSERT INTO cooks_recipes_per_episode (current_year,episode_number,rec_name,cook_id)
SELECT current_year , episode_number , rec_name , cook_id 
FROM cooks_recipes_per_episode_ ;
/*DELETE FROM cooks_recipes_per_episode_;
DELETE FROM available_national_cuisines; 
DELETE FROM security_purposes_cooks; 
DELETE FROM security_purposes_recipes;
DELETE FROM available_recipes;
DELETE FROM available_cooks;*/ 
END;
//
DELIMITER ;

 

CALL build_the_contest(2020,2024);
DROP TRIGGER CooksAndRecipes_inserts_in_result_here; 
DROP TABLE cooks_recipes_per_episode_ ;
DROP TABLE  security_purposes_cooks;
DROP TABLE security_purposes_recipes;
DROP TABLE security_purposes_national_cuisine;
DROP TABLE available_national_cuisines;
DROP TABLE available_recipes;
DROP TABLE available_cooks;
DROP PROCEDURE build_the_contest;
DROP PROCEDURE creation_of_episode; 
DROP PROCEDURE updating_security_check_cooks;
DROP PROCEDURE updating_security_check_recipes;
DROP PROCEDURE updating_security_check_national_cuisines;
