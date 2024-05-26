DROP ROLE IF EXISTS cook_role;
DROP USER IF EXISTS Cook;
DROP ROLE IF EXISTS administrator_role;
DROP USER IF EXISTS Administrator;
DROP VIEW IF EXISTS recipes_assigned_to_cook;

CREATE ROLE cook_role;
CREATE ROLE administrator_role;

GRANT SELECT ON cooking.belongs_to_thematic_unit TO cook_role;
GRANT SELECT ON cooking.cooks TO cook_role;
GRANT SELECT ON cooking.cooks_belongs_to_national_cuisine TO cook_role;
GRANT SELECT ON cooking.cooks_recipes_per_episode TO cook_role;
GRANT SELECT ON cooking.episodes_per_year TO cook_role;
GRANT SELECT ON cooking.equipment TO cook_role;
GRANT SELECT ON cooking.evaluation TO cook_role;
GRANT SELECT ON cooking.food_group TO cook_role;
GRANT SELECT ON cooking.ingredients TO cook_role;
GRANT SELECT ON cooking.needs_ingredient TO cook_role;
GRANT SELECT ON cooking.recipe TO cook_role;
GRANT SELECT ON cooking.step TO cook_role;
GRANT SELECT ON cooking.tags TO cook_role;
GRANT SELECT ON cooking.thematic_unit TO cook_role;
GRANT SELECT ON cooking.tips TO cook_role;
GRANT SELECT ON cooking.type_of_meal TO cook_role;
GRANT SELECT ON cooking.uses_equipment TO cook_role;
GRANT SELECT ON cooking.winners TO cook_role;

GRANT INSERT 
ON cooking.recipe
TO cook_role;

GRANT INSERT 
ON cooking.needs_ingredient
TO cook_role;

GRANT INSERT 
ON cooking.ingredients
TO cook_role;

GRANT INSERT 
ON cooking.food_group
TO cook_role;

CREATE VIEW recipes_assigned_to_cook AS
SELECT *
FROM recipe
WHERE rec_name IN (
	SELECT rec_name 
    FROM cooks_recipes_per_episode
    WHERE cook_id = (
		SELECT cook_id 
        FROM cook_credentials
    )
);	

GRANT UPDATE, SELECT
ON cooking.recipes_assigned_to_cook
TO cook_role;

CREATE USER Cook  
IDENTIFIED BY 'cook'
DEFAULT ROLE cook_role;

GRANT PROCESS, RELOAD, SUPER
ON *.*
TO administrator_role;

GRANT SYSTEM_USER
ON *.*
TO administrator_role;

GRANT SELECT, SHOW VIEW, TRIGGER, LOCK TABLES, CREATE, ALTER, INSERT, UPDATE, REFERENCES, CREATE VIEW, DROP
ON cooking.*
TO administrator_role;

CREATE USER Administrator  
IDENTIFIED BY 'admin'
DEFAULT ROLE administrator_role;

