INSERT INTO food_group
VALUES ('Dairy', 'All milk products', 'Delicious But Makes You FAT');

INSERT INTO ingredients
VALUES ('Chocolate', 550, 'Dairy');

INSERT INTO recipe
VALUES ('Chocolate Pie', 'Pastry', '5', 'No idea how to make this', 60, 20, 8, 'Chocolate', 23, 52, 4, 300);

INSERT INTO thematic_unit
VALUES ('Desserts', 'Sweet recipes for everyday desserts');

INSERT INTO belongs_to_thematic_unit
VALUES ('Chocolate Pie', 'Desserts');

INSERT INTO needs_ingredient
VALUES ('Chocolate', 'Chocolate Pie', '100g');

SELECT * FROM needs_ingredient;