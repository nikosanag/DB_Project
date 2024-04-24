SELECT recipe.rec_name AS name, uses_equipment.equipment_name AS equipment, food_group.recipe_description AS malakia, ingredients.calories_per_100gr AS calories_of_main_ingredient_per_100gr
FROM recipe
JOIN uses_equipment ON uses_equipment.rec_name = recipe.rec_name
JOIN ingredients ON ingredients.name_of_ingredient = recipe.name_of_main_ingredient
JOIN food_group ON ingredients.name_of_food_group = food_group.name_of_food_group;



-- Recipe Name, equipment, malakia, ?calories to main ingredient