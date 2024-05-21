SET SQL_SAFE_UPDATES = 0; /*useful so i can delete anything from a table*/ 

Create table national_cuisine(
name_national varchar(50),
primary key (name_national)
);

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
	PRIMARY KEY(cook_id)
);

CREATE TABLE available_recipes(
	rec_name VARCHAR(50),
	national_cuisine VARCHAR(50), 
	PRIMARY KEY(rec_name)
);

DELIMITER // 
CREATE PROCEDURE updating_security_check_cooks(in cooker_id INT) 
BEGIN    
	IF (SELECT COUNT(*) FROM available_cooks WHERE cooker_id = cook_id) = 0 /*isnt in table security_purposes*/
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
CREATE PROCEDURE updating_security_check_recipes(in rec_nam VARCHAR)
BEGIN
		IF (SELECT COUNT(*) FROM available_recipes WHERE rec_nam = rec_name) =0 /*isnt in table security_purposes recipes*/
        THEN INSERT INTO security_purposes_recipes(rec_name,triggering_number) VALUE (rec_nam,1); 
        
        ELSE
			UPDATE security_purposes_recipes
            SET triggering_number = triggering_number + 1
            WHERE rec_nam = rec_name;
            END IF;
END; 
/
DELIMITER // /*SUPER IMPORTANT for inserting recipes and cooks...open on your own risk...I warned you!*/
CREATE TRIGGER CooksAndRecipes_inserts_in_result_here BEFORE INSERT ON cooks_recipes_per_episode_
FOR EACH ROW
BEGIN

	DECLARE id INT;
	DECLARE rec_name VARCHAR(50); 

/*αναζητα καταλληλο cook.Ο καταλληλος ειναι ενας που δεν ειναι ακομα στο security_purposes_cooks ή αν ειναι δεν ειναι το triggering number = 3...και ενας που ανηκει σε αυτη την εθνικη κουζινα*/
	SET id = (SELECT cook_id FROM available_cooks WHERE (((SELECT trigerring_number FROM security_purposes_cooks where cook_id = id) < 3) OR ((SELECT 1 FROM security_purposes_cooks WHERE cook_id = id) != 1)) AND (SELECT 1 FROM cooks_belongs_to_national_cuisine WHERE (cook_id = id AND type_of_national_cuisine_that_belongs_to = NEW.national_cuisine)) = 1);
	SET NEW.cook_id = id; 
/*τον καταργει απο το πινακα υποψηφιων ,αφου θα χει μπει, για αυτο το επεισοδιο*/
	DELETE FROM available_cooks  
	WHERE cook_id = id; 
 
 /*updates the table security_purposes*/ 
  CALL updating_security_check_cooks(id); 
    
 /*αναζητα καταλληλο recipe ,το οποιο πρεπει να αντιστοιχιζεται στην εθνικη κουζινα και δεν εχει μπει σε τρια συνεχομενα επεισοδια ή δεν εχει μπει καν στα τρια τελευταια επεισοδια και δεν βρισκονται στο security_purposes_recipes*/
	SET rname = (SELECT rec_name FROM available_recipes WHERE (NEW.national_cuisine = national_cuisine) AND ((SELECT triggering_number FROM security_purposes_recipes WHERE rname = rec_name)<3 OR (SELECT 1 FROM security_purposes_recipes where rname = rec_name)!=1));
	SET NEW.rec_name = rname; 
 /*διαγραφει αυτο το recipe για αυτο το επεισοδιο*/
	DELETE FROM available_recipes
    WHERE rec_name = rname; 
    
 /*updates the table security_purposes*/ 
	CALL updating_security_check_recipes(rname);
    
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
	
    /*DELETE FROM available_cooks;
    DELETE FROM available_recipes;*/
    DELETE FROM security_purposes_cooks WHERE cook_id = (SELECT cook_id FROM available_cooks);
    DELETE FROM available_cooks;
    DELETE FROM security_purposes_recipes WHERE rec_name = (SELECT rec_name FROM available_recipes);
    DELETE FROM available_recipes; 
END;
//
DELIMITER;


DELIMITER // 
CREATE PROCEDURE build_the_contest(IN starting_year INT,end_year INT) 
BEGIN
DECLARE count INT; 
DECLARE count_inside INT; 
SET count = starting_year ; 


INSERT INTO national_cuisine 
SELECT DISTINCT type_of_national_cuisine_that_belongs_to FROM cooks_belongs_to_national_cuisine;


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
DELETE FROM cooks_recipes_per_episode_;
DELETE FROM national_cuisine; 
DELETE FROM security_purposes_cooks; 
DELETE FROM security_purposes_recipes;
DELETE FROM available_recipes;
DELETE FROM available_cooks; 
END;
//
DELIMITER ;




CALL build_the_contest(2019,2024);

