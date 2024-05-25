DROP ROLE IF EXISTS cook_role;
DROP USER IF EXISTS Cook;
DROP ROLE IF EXISTS administrator_role;
DROP USER IF EXISTS Administrator;
DROP VIEW IF EXISTS recipes_assigned_to_cook;

CREATE ROLE cook_role;

GRANT SELECT 
ON *
TO cook_role;	

GRANT INSERT 
ON recipe
TO cook_role;

CREATE VIEW recipes_assigned_to_cook AS
SELECT *
FROM recipe
WHERE rec_name = (
	SELECT rec_name 
    FROM cooks_recipes_per_episode
    WHERE cook_id = (
		SELECT cook_id 
        FROM cook_credentials
    )
);	

GRANT UPDATE 
ON recipes_assigned_to_cook
TO cook_role;

CREATE USER Cook  
IDENTIFIED BY 'cook'
DEFAULT ROLE cook_role;

GRANT SELECT, SHOW VIEW, TRIGGER, LOCK TABLES, PROCESS, RELOAD, CREATE, ALTER, INSERT, UPDATE
ON *
TO administrator_role;
FLUSH PRIVILEGES;

CREATE USER Administrator  
IDENTIFIED BY 'admin'
-- DEFAULT ROLE administrator_role;


