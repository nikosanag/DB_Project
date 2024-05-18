CREATE TABLE security_purposes(
cook_id INT(11),
triggering_number INT(11),
PRIMARY KEY (cook_id)
);

CREATE TABLE available_cooks LIKE cooks_belongs_to_national_cuisine ;

 DELIMITER // 
CREATE PROCEDURE creation_of_episode(IN requested_year INT, requested_episode INT)
BEGIN

INSERT INTO cooks_recipes_per_episode (current_year,episode_number,national_cuisine)
SELECT requested_year,requested_episode,national_cuisine
FROM national_cuisine
ORDER BY RAND()
LIMIT 10; 




END
//
DELIMITER ;




