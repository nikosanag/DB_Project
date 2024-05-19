SET SQL_SAFE_UPDATES = 0;

Create table national_cuisine(
name_national varchar(50),
primary key (name_national)
);

INSERT INTO national_cuisine 
SELECT DISTINCT type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine;

CREATE TABLE cooks_recipes_per_episode_(
current_year INT(11) ,
episode_number INT(11) ,
national_cuisine VARCHAR(11),
rec_name VARCHAR(50),
cook_id INT(11),
PRIMARY KEY (current_year,episode_number,national_cuisine) 
); 

CREATE TABLE security_purposes(
	cook_id INT(11),
	triggering_number INT(11),
	PRIMARY KEY (cook_id)
);

CREATE TABLE available_cooks (
	cook_id INT(11),
	type_of_national_cuisine_that_belongs_to VARCHAR(50),
	PRIMARY KEY(cook_id)
);
CREATE TABLE available_recipes(
	rec_name VARCHAR(50),
	national_cuisine VARCHAR(50), 
	PRIMARY KEY(rec_name)
);

DELIMITER // 
CREATE PROCEDURE updating_security_check(in cooker_id INT) 
BEGIN

	
    
	IF (SELECT COUNT(*) FROM available_cooks WHERE cooker_id = cook_id) = 0 /*isnt in table security_purposes*/
	THEN
		INSERT INTO security_purposes(cook_id,triggering_number) VALUE (cooker_id,1) ;
	
    ELSE 
		UPDATE security_purposes 
        SET triggering_number = triggering_number + 1 
        WHERE cook_id = cooker_id; 
	END IF;
 
END;
//
DELIMITER ; 


/*initializes the procedure of a single episode.*/
DELIMITER // 
CREATE PROCEDURE creation_of_episode(IN requested_year INT, requested_episode INT)
BEGIN
	INSERT INTO available_cooks(cook_id,type_of_national_cuisine_that_belongs_to) SELECT cook_id,type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine ORDER BY RAND() ; 
    INSERT INTO available_recipes(rec_name,national_cuisine) SELECT rec_name,national_cuisine FROM recipe ORDER BY RAND() ;

	INSERT INTO cooks_recipes_per_episode_ (current_year,episode_number,national_cuisine)
	SELECT requested_year,requested_episode,name_national
	FROM national_cuisine
	ORDER BY RAND()	
	LIMIT 10; 
    
	INSERT INTO judges (current_year,episode_number,cook_id)
	SELECT requested_year,requested_episode,cook_id
	FROM available_cooks
	ORDER BY RAND()	
	LIMIT 3;    
	
    DELETE FROM available_cooks;
    DELETE FROM available_recipes;
    DELETE FROM security_purposes WHERE ((SELECT COUNT(*) FROM available_cooks WHERE security_purposes.cook_id = available_cooks.cook_id) > 0);
END;
//
DELIMITER;


DELIMITER // 
CREATE PROCEDURE build_the_contest(IN starting_year INT,end_year INT) 
BEGIN
DECLARE count INT; 
DECLARE count_inside INT; 
SET count = starting_year ; 

while (count<end_year+1) DO
	BEGIN
    SET count_inside = 0;    
    WHILE (count_inside < 10) DO
		BEGIN
		CALL creation_of_episode(count,count_inside) ;
        SET count_inside = count_inside+1 ; 
        END;
        END WHILE; 
	SET count = count +1 ; 
	END; 
    END WHILE;


INSERT INTO cooks_recipes_per_episode (current_year,episode_number,rec_name,cook_id)
SELECT current_year , episode_number , rec_name , cook_id 
FROM cooks_recipes_per_episode_ ;
DROP TABLE cooks_recipes_per_episode_;
DROP TABLE national_cuisine; 
DROP TABLE security_purposes; 
DROP TABLE available_recipes;
DROP TABLE available_cooks; 
END;
//
DELIMITER ;


DELIMITER // /*SUPER IMPORTANT for inserting recipes and cooks...open on your own risk...I warned you!*/
CREATE TRIGGER CooksAndRecipes_inserts_in_result_here BEFORE INSERT ON cooks_recipes_per_episode_
FOR EACH ROW
BEGIN

	DECLARE id INT;
	DECLARE rec_name VARCHAR(50); 

/*αναζητα καταλληλο cook*/
	SET id = (SELECT cook_id FROM available_cooks WHERE (SELECT trigerring_number FROM security_purposes where cook_id = id) < 3) ;
	SET NEW.cook_id = id; 
/*τον καταργει απο το πινακα υποψηφιων ,αφου θα χει μπει*/
	DELETE FROM available_cooks  
	WHERE cook_id = id; 
 
 /*updates the table security_purposes*/ 
 
 CALL updating_security_check(id); 
    
/*αναζητα καταλληλο recipe*/
	SET rname = (SELECT rec_name FROM available_recipes WHERE NEW.national_cuisine = national_cuisine);
	SET NEW.rec_name = rname; 

	DELETE FROM available_recipes
    WHERE rec_name = rname; 
    
END;
//
DELIMITER ; 


CALL build_the_contest(2000,2024);

