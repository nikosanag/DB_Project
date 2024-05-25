import mysql.connector
import random
from faker import Faker
from faker_food import FoodProvider
from datetime import datetime
data = Faker()
data.add_provider(FoodProvider)

# # -------- BIG DATA --------
# INGREDIENTS = 400
# FOOD_GROUPS = 12
# COOKS = 200
# RECIPES = 300
# EQUIPMENT = 96
# THEM_UNITS = 30
# NATIONAL_CUISINES = 118

# -------- SMALL DATA --------
INGREDIENTS = 250
FOOD_GROUPS = 12
COOKS = 100
RECIPES = 200
EQUIPMENT = 50
THEM_UNITS = 30
NATIONAL_CUISINES = 30

# # -------- QUERRY TESTING --------
# INGREDIENTS = 60
# FOOD_GROUPS = 12
# COOKS = 30
# RECIPES = 40
# EQUIPMENT = 50
# THEM_UNITS = 30
# NATIONAL_CUISINES = 20

#--------------------------------------------- FOOD GROUPS ---------------------------------------------
# NAME  --  primary key
name_of_food_group = [
  "Spices and essential oils",
  "Coffee, tea and their products",
  "Preserved foods", "Sweeteners", 
  "Fats and oils", "Milk, eggs and their products",
  "Meat and its products", "Fish and their products",
  "Cereals and their products",
  "Various foods of plant origin", 
  "Products with sweeteners", "Various drinks"
]

# GROUP DESCRIPTION
description_of_food_group = []
for _ in range (FOOD_GROUPS):
  description_of_food_group.append(data.unique.sentence()[:50])

# RECIPE DESCRIPTION
recipe_description = [
  "Seafood",
  "Poultry",
  "Meat",
  "Vegetarian/Vegan",
  "Vegetable-Based",
  "Fruit-Based",
  "Grain-Based",
  "Dairy-Based",
  "Nut and Seed-Based",
  "Egg-Based",
  "Legume-Based",
  "Mushroom-Based"
]

# IMAGE URL
image_of_food_group = []
for _ in range(FOOD_GROUPS):
  url = f"https://dummyimage.com/{random.randint(1000,2000)}x{random.randint(1000,2000)}"
  image_of_food_group.append(url)

# IMAGE DESCRIPTION
image_of_food_group_desc = []
for _ in range(FOOD_GROUPS):
  image_of_food_group_desc.append(data.sentence())
# -----------------------------------------------------------------------------------------------------




#-------------------------------------------- INGREDIENTS ---------------------------------------------
# NAME  --  primary key
name_of_ingredient = []
for _ in range(INGREDIENTS):
  name_of_ingredient.append(data.unique.ingredient())


# CALORIES PER 100g
calories_per_100gr = []
for _ in range(INGREDIENTS):
  calories_per_100gr.append(random.randint(15, 650))

# NAME OF FOOD GROUP  --  foreign key references FOOD GROUP
ingredient_of_food_group = []
for _ in range(INGREDIENTS):
  dice = random.randint(1, 10)
  if dice <= 2:
    ingredient_of_food_group.append(random.choice(name_of_food_group))
  else:
    ingredient_of_food_group.append(random.choice(name_of_food_group[:4]))

# IMAGE URL
image_of_ingredient = []
for _ in range(INGREDIENTS):
  url = f"https://dummyimage.com/{random.randint(1000,2000)}x{random.randint(1000,2000)}"
  image_of_ingredient.append(url)

# IMAGE DESCRIPTION
image_of_ingredient_desc = []
for _ in range(INGREDIENTS):
  image_of_ingredient_desc.append(data.sentence())
# -----------------------------------------------------------------------------------------------------




#------------------------------------------------ RECIPES ---------------------------------------------
# NAME  --  primary key
names1 = ["Jamaican Jerk Chicken", "Pasta Salad", "Lasagna", "Hearty Pancakes", "Summer Garden Couscous Salad", "Moussaka" ,"Squash Corn Chowder", "White beans, tomatoes, and spinach", "Spaghetti", "Scones", "Stir-Fry", "Rustic Italian Tortellini Soup", "Swedish Meatballs", "Barley Beef Skillet", "Souvlaki", "Southwest Beef & Rice Skillet", "Glazed Pork Chops with Corn Bread Dressing", "Fried Rice", "Zesty Sausage & Beans", "Prosciutto Pasta Toss", "Cashew Chicken with Noodles", "Herb Chicken with Honey Butter", "French Toast", "Swedish Pancakes", "Baked Cheddar Eggs & Potatoes", "Baked Mostaccioli", "Ravioli with Snap Peas", "Cloverleaf Rolls", "Greek Yogurt and Honey Blueberry Muffins", "Whole Grain Waffles", "Lemon Bars", "Qahaq Cookies", "Blondies with Nutella", "Hot Chocolate", "Chocolate Mousse", "S'mores Cookie Bars", "Orange Chicken", "Tostadas", "Black Bean Stuffed Sweet Potatoes", "Asian Shredded Beef", "Capellini with sausage, spinach, and jalapeno", "Crispy Chicken with Kale", "Roast Chicken Grain Bowl", "Chicken thighs with barley and peas", "Rice noodles with meatballs and bok choy", "Paprika Pork with Roasted Potatoes and Dill Cream", "Chicken cutlets with carrot and kale salad", "Gnocchi and sweet potatoes", "Shepherd's Pie", "Garlic Parmesan Chicken", "Turkey Pot Pie", "Balsamic Bacon Brussels Sprouts", "Lemon Red Potatoes", "Potato and Corn Chowder", "Thai Chicken", "Italian Fagoli Vegetable Soup", "Blueberry Pie", "Chocolate Pudding", "Browned Butter Beets", "Turkey Soup with Homemade Noodles", "Home fries", "Chocolate Raspberry Torte", "Golden Latte", "Fig Shake", "Lentil Soup", "Buckwheat Tabboulah", "Lentil Rice Bowls with Egg", "Italian Vegetable Lentil Soup", "One Pot Chicken & Potatoes", "Sweet Korean Lentils", "Buckwheat Beetroot Salad", "New Potato Lentil Salad", "Ham & Potato Soup", "Lemon Dill Potatoes", "BBQ Lentils", "Healthy Buckwheat Soup", "Buckwheat Chicken Pilaf", "Vegetable Noodle Soup", "Bacon and Honey Potato Salad", "Pretzel Sticks", "Golden French Lentil Soup", "Lentil Shepherd's Pie", "Honey Lime Chicken", "Lentil Curry", "Dutch Oven Bread", "Potato Apple Roast", "Baking Powder Biscuits", "Sugar Cookies", "Potato Curry", "Bucatini all'Amatriciana", "Brioche Chocolate Rolls", "Naan", "Lemon Poppy Seed Scones", "Balsamic Dijon Root Vegetables", "Best Baked Chicken Legs", "Spanish Lentil Soup", "Chocolate Chip Irish Soda Bread", "Malteese Gilatti", "Buckwheat Carrot and Onion", "Sweet Potatoes with Yogurt and Chickpeas", "Spanish Chickpeas", "Lemon Fettuchini", "Chickpea Masala", "Chickpea Broccoli Pesto", "Thai Veggie Soup", "Buttery Herb Chicken", "Rosemary Parsnips", "Balsamic Potatoes and Asparagus", "Quinoa Brussels Sweet Potato Salad", "Thai Peanut Cabbage Quinoa", "Lemon Garlic Asparagus with Orzo", "Moroccan Sweet Potato Lentil Stew", "Chia Crusted Salmon", "Pinto Beans and Tomatillo Cilantro Lime Rice", "Thai Squash Soup", "Roasted Carrot & Peanut Sauce", "Majoram White Wine Chicken", "Marjoram Carrots", "Soy Mustard Salmon", "Chive Butter Radishes", "Mango Chutney", "Vegetarian Chili", "Sweet Potato Breakfast Burritos", "Roasted Sweet Potato Lentil Salad", "Cornbread", "Brussel Honey Lentil Quinoa", "Lentil Sweet Potato Curry", "Gnocci and white beans", "Pad Thai", "Kung Pao Chicken", "Mediterranean Tuna Steaks", "Spicy Black Bean Nachos", "Tomato Basil Soup", "Chewy Chocolate Chip Cookies", "Quinoa Peanut Kale Curry", "Sweet Potato Lentil Curry with Pickled Onion", "Sardine Mediterranean Pasta", "Prosciutto apple flatbread pizza", "Dill Cucumber Salmon", "Vegetable Couscous", "Talapia Tacos", "Roasted Mackerel", "Lentil Salsa Soup", "Pesto Tomato Penne", "Black Bean Soup", "Balsamic Pork Chops"]
names2 = ["Spaghetti Carbonara", "Chicken Alfredo", "Beef Stroganoff", "Vegetable Stir Fry", "Chicken Tikka Masala", "Fish Tacos", "Pulled Pork Sandwiches", "Eggplant Parmesan", "Caesar Salad", "Shrimp Scampi", "Chicken Pot Pie", "Lamb Gyros", "Beef Wellington", "Vegetable Lasagna", "Pad Thai", "Butternut Squash Soup", "Grilled Cheese Sandwich", "Mushroom Risotto", "Chicken Quesadilla", "Turkey Club Sandwich", "Margherita Pizza", "Lobster Bisque", "Baked Ziti", "Beef Tacos", "Chicken Caesar Wrap", "Salmon Teriyaki", "Clam Chowder", "BBQ Ribs", "Falafel Wrap", "Stuffed Peppers", "Chicken Curry", "Ratatouille", "Greek Salad", "Cheeseburger", "Vegetable Curry", "Pulled Chicken", "Spinach Quiche", "Pasta Primavera", "Chicken Fajitas", "Tom Yum Soup", "Beef Burritos", "Egg Salad Sandwich", "Beef Enchiladas", "Minestrone Soup", "Stuffed Mushrooms", "Lamb Kebabs", "Chicken Satay", "Gnocchi with Pesto", "Vegetarian Chili", "Steak Frites", "Chicken Parmesan", "Pork Schnitzel", "Grilled Shrimp", "Tuna Salad", "Vegetable Samosas", "Chicken Piccata", "French Onion Soup", "Lamb Shank", "Seafood Paella", "Spinach and Artichoke Dip", "BBQ Chicken Pizza", "Vegetarian Pizza", "Stuffed Cabbage Rolls", "Shrimp Fried Rice", "Shepherd’s Pie", "Chicken Alfredo Pasta", "Garlic Butter Shrimp", "Tomato Basil Soup", "Beef Bourguignon", "Chicken Noodle Soup", "Grilled Salmon", "Pork Tenderloin", "Chicken Cordon Bleu", "Eggplant Rollatini", "Vegetable Quesadilla", "Spaghetti Bolognese", "Tuna Casserole", "Vegetarian Tacos", "Beef and Broccoli", "Chicken Tenders", "Shrimp Tacos", "French Toast", "Beef Stew", "Chicken Shawarma", "Vegetable Soup", "Lamb Chops", "Cauliflower Steak", "Chicken Burritos", "Crab Cakes", "Tortellini Alfredo", "Vegetable Paella", "Baked Salmon", "Beef Kebabs", "Chicken Marsala", "Margarita Chicken", "Lentil Soup", "Beef Chili", "Vegetable Biryani", "Clam Linguine", "Chicken Chimichangas", "Pulled Pork Tacos", "Stuffed Shells", "Chicken Pad Thai", "Grilled Chicken Salad", "Tomato Soup", "Beef Meatballs", "Vegetable Spring Rolls", "Chicken Katsu", "Shrimp Pad Thai", "Stuffed Portobello Mushrooms", "Pulled Chicken Tacos", "Salmon Salad", "Spinach Lasagna", "Chicken and Dumplings", "Vegetable Stir-Fried Noodles", "Thai Peanut Noodles", "Honey Garlic Salmon", "Black Bean Burgers", "Lemon Ricotta Cookies", "Seared Steak & Mashed Potatoes", "Moroccan Chickpea Stew", "Korean BBQ Chicken Bowls", "Spiced Apple Crisp", "Flank Steak Fajitas", "Rainbow Veggie Stir-Fry", "Double Chocolate Brownies", "Veggie Burgers", "Cheesy Chicken Enchiladas"]
for _ in range(37):
  names1.append(data.unique.dish())
names3 = names1 + names2
rec_name = list(set(names3))[:RECIPES]

# TYPE
types = ['Pastry','Regular']
rec_type = []
for _ in range(RECIPES):
  dice = random.randint(1, 10)
  if dice <= 7:
    rec_type.append(types[1])
  else:
    rec_type.append(types[0])

# DIFFICULTY
level_of_diff = []
for _ in range(RECIPES):
  level_of_diff.append(random.randint(1, 5))

# DESCRIPTION
short_descr = []
for _ in range(RECIPES // 2):
  short_descr.append(data.dish_description()[:50])
for _ in range(RECIPES - (RECIPES // 2)):
  short_descr.append(data.sentence()[:50])

# PREPARATION TIME 
prep_time = []
for _ in range(RECIPES):
  prep_time.append(random.randint(20, 70))

# COOKING TIME 
cooking_time = []
for _ in range(RECIPES):
  cooking_time.append(random.randint(30, 100))

# PORTIONS
portions = []
for _ in range(RECIPES):
  portions.append(random.randint(1,4))

# MAIN INGREDIENT  --  foreign key references INGREDIENTS
name_of_main_ingredient = []
for _ in range(RECIPES):
  name_of_main_ingredient.append(random.choice(name_of_ingredient))

# FAT
grams_of_fat_per_portion = []
for _ in range(RECIPES):
  grams_of_fat_per_portion.append(random.randint(5, 30))

# CARBONHYDRATES
grams_of_carbohydrates_per_portion = []
for _ in range(RECIPES):
  grams_of_carbohydrates_per_portion.append(random.randint(10, 50))

# PROTEIN
grams_of_proteins_per_portion = []
for _ in range(RECIPES):
  grams_of_proteins_per_portion.append(random.randint(10, 45))

# NATIONAL CUISINE
recipe_belongs_to_national_cuisine = []
all_national_cuisines = []
for _ in range(118):
  all_national_cuisines.append(data.unique.ethnic_category())

existing_cuisines = random.sample(all_national_cuisines, NATIONAL_CUISINES)
for _ in range(RECIPES):
  recipe_belongs_to_national_cuisine.append(random.choice(existing_cuisines))

# IMAGE URL
image_of_recipe = []
for _ in range(RECIPES):
  url = f"https://dummyimage.com/{random.randint(1000,2000)}x{random.randint(1000,2000)}"
  image_of_recipe.append(url)

# IMAGE DESCRIPTION
image_of_recipe_desc = []
for _ in range(RECIPES):
  image_of_recipe_desc.append(data.sentence())
# -----------------------------------------------------------------------------------------------------




#------------------------------------------- NEEDS INGREDIENT -----------------------------------------
# RECIPE i NEEDS LIST OF (INGREDIENT, QUANTITY)
recipe_needs_ingredient = []
for _ in range(RECIPES):
  recipe_needs_ingredient.append([])

for i in range(RECIPES):  #inserting main ingredient
  main = name_of_main_ingredient[i]
  quantity = random.randint(30, 400)
  recipe_needs_ingredient[i].append((main, quantity))


def ingExists(num_of_recipe , ingr):
  for pair in recipe_needs_ingredient[num_of_recipe]:
    if (pair[0] == ingr):
      return True
  return False


for i in range(RECIPES):
  rng = random.randint(5, 16)
  for j in range(rng):
    ing = random.choice(name_of_ingredient)
    if ingExists(i, ing):
      continue
    quantity = random.randint(30, 400)
    append_value = (ing, quantity)
    recipe_needs_ingredient[i].append(append_value)
# -----------------------------------------------------------------------------------------------------




#--------------------------------------------- TYPE OF MEAL -------------------------------------------
# RECIPE i HAS LIST OF MEAL TYPES
type_of_meal = ["Breakfast", "Lunch", "Dinner", "Supper", "Elevenses", "Tiffin", "Banquet"]
recipe_has_meal_type = []
for _ in range(RECIPES):
  recipe_has_meal_type.append([])

for i in range(RECIPES):
  recipe_has_meal_type[i] += random.sample(type_of_meal, random.randint(1, len(type_of_meal)))
# -----------------------------------------------------------------------------------------------------




#------------------------------------------------- TAGS -----------------------------------------------
# RECIPE i HAS LIST OF TAGS
tags = ["Main Dish", "Salad", "Brunch", "Baking", "Dessert", "Snack", "Cold Dish", "Hot Dish", "Quick-Lunch"]

recipe_has_tag = []
for _ in range(RECIPES):
  recipe_has_tag.append([])

for i in range(RECIPES):
  recipe_has_tag[i] += random.sample(tags, random.randint(1, len(tags)))
# -----------------------------------------------------------------------------------------------------




#------------------------------------------------- TIPS -----------------------------------------------
# RECIPE i HAS LIST OF TIPS
tips = ["Make dough long before", "Use half whole wheat flour", "Add bacon", "Whisk on stove until thick", "Roast for long", "Use more buckwheat", "Add rice in after 15 minutes and use more water", "Don't cook bacon too long", "Flip pretzel sticks half way through", "Doesn't use the stove!  Sear chicken skin longer (+5 minutes)", "Bake at 180 for 25 min with lid and 15 min without", "Use less tomato, more cream", "Don't fry too long", "Burns in an enamel pot", "Can use enamel pot instead of skillet", "Hard to get them toasty", "Don't forget to make Naan dough ahead of time", "Can throw in carrots as well", "Potatoes for 25 min then aspargus for 15 min", "Use less spices to allow mango and feta flavors more room", "Combined two rexpies, use 1 c lentils, 3 sweet potatoes and add more celery and spinach.", "Also use 1/4 tsp each paprika and cumin in dressing.", "Would be better with chicken breast, not legs", "Make some rice to go with it"]

recipe_has_tip = []
for _ in range(RECIPES):
  recipe_has_tip.append([])

for i in range(RECIPES):
  recipe_has_tip[i] += random.sample(tips, random.randint(0, 3))
# -----------------------------------------------------------------------------------------------------




#---------------------------------------------- EQUIPMENT ---------------------------------------------
# NAME  --  primary key 
equipment_name = ["Air fryer", "Bachelor griller", "Barbecue grill", "Beehive oven", "Blender", "Bowl" , "Brasero", "Brazier", "Bread machine", "Burjiko", "Butane torch", "Chapati maker", "Cheesemelter", "Chocolatera", "Chiller" , "Chorkor oven", "Clome oven", "Comal (cookware)", "Combi steamer", "Communal oven", "Convection microwave", "Convection oven", "Corn roaster", "Crepe maker", "Deep fryer", "Earth oven", "Electric cooker", "Espresso machine", "Field kitchen", "Fire pot", "Flattop grill", "Food steamer", "Fufu machine", "Grater" ,"Griddle", "Halogen oven", "Haybox", "Hibachi", "Horno", "Hot box (appliance)", "Hot plate", "Instant Pot", "Kamado", "Kitchener range", "Kujiejun", "Kyoto box", "Makiyakinabe", "Masonry oven", "Mess kit", "Microwave oven", "Multicooker", "Oven", "On2cook", "Pan", "Pancake machine", "Panini sandwich grill", "Popcorn maker", "Pressure cooker", "Pressure fryer", "Reflector oven", "Remoska", "Rice cooker", "Rice polisher", "Roasting jack", "Rocket mass heater", "Rotimatic", "Rotisserie", "Russian oven", "Sabbath mode", "Salamander broiler", "Samovar", "Sandwich toaster", "Self-cleaning oven", "Shichirin", "Slow cooker", "Solar cooker", "Sous-vide cooker", "Soy milk maker", "Stove", "Susceptor", "Tabun oven", "Tandoor", "Tangia", "Thermal immersion circulator", "Toaster and toaster ovens", "Turkey fryer", "Vacuum fryer", "Waffle iron", "Wet grinder", "Wine cooler", "Wood-fired oven", "Coffee percolator", "Coffeemaker", "Electric water boiler", "Instant hot water dispenser", "Kettle"][:EQUIPMENT]

# MANUAL
instruction_manual = []
for _ in range(EQUIPMENT):
  instruction_manual.append(data.sentence() + ' ' + data.sentence() + ' ' + data.sentence())

# IMAGE URL
image_of_equipment = []
for _ in range(EQUIPMENT):
  url = f"https://dummyimage.com/{random.randint(1000,2000)}x{random.randint(1000,2000)}"
  image_of_equipment.append(url)

# IMAGE DESCRIPTION
image_of_equipment_desc = []
for _ in range(EQUIPMENT):
  image_of_equipment_desc.append(data.sentence())
# -----------------------------------------------------------------------------------------------------




#-------------------------------------------- USES EQUIPMENT ------------------------------------------
# RECIPE i USES LIST OF EQUIPMENT
recipe_uses_equipment = []

for _ in range(RECIPES):
  recipe_uses_equipment.append([])

for i in range(RECIPES): 
  recipe_uses_equipment[i] += random.sample(equipment_name, random.randint(4, 10))
# -----------------------------------------------------------------------------------------------------




#------------------------------------------------- STEP -----------------------------------------------
# INSTRUCTIONS
instructions = ["Preheat the oven to 350°F (175°C).", "Mix flour, sugar, and eggs in a bowl.", "Add butter and milk to the mixture.", "Pour the batter into a greased baking pan.", "Bake for 25-30 minutes until golden brown.", "Let it cool before serving.", "Chop the vegetables into small pieces.", "Heat oil in a pan over medium heat.", "Add garlic and onions to the pan.", "Stir in the vegetables and cook for 5-7 minutes.", "Season with salt and pepper.", "Serve hot.", "Boil water in a large pot.", "Add pasta to the boiling water.", "Cook for 8-10 minutes until al dente.", "Drain the pasta and set aside.", "Heat sauce in a separate pan.", "Combine pasta and sauce, and mix well.", "Serve with grated cheese on top.", "Marinate the chicken with spices and yogurt.", "Let it sit for at least 30 minutes.", "Heat oil in a large skillet over medium-high heat.", "Add the chicken to the skillet and cook for 6-8 minutes per side.", "Reduce the heat and let it simmer for 15 minutes.", "Garnish with fresh cilantro before serving.", "Rinse the rice under cold water until the water runs clear.", "Combine rice and water in a pot.", "Bring to a boil, then reduce heat to low.", "Cover and simmer for 18-20 minutes.", "Remove from heat and let it stand covered for 5 minutes.", "Fluff the rice with a fork before serving."]

# RECIPE i FOLLOWS LIST OF (STEP_NUM, INSTRUCTIONS)
recipe_follows_steps = []
for _ in range(RECIPES):
  recipe_follows_steps.append([])

for i in range(RECIPES):
  rng = random.randint(7, 25)
  for j in range(rng):
    append_value = (j + 1, random.choice(instructions))
    recipe_follows_steps[i].append(append_value)
# -----------------------------------------------------------------------------------------------------




#-------------------------------------------- THEMATIC UNIT -------------------------------------------
# NAME
name_of_thematic_unit = ["Thanksgiving desserts", "Christmas desserts", "Easter desserts", "Risotto dishes", "Summer salads", "Holiday appetizers", "Breakfast smoothies", "Pasta salads", "Picnic sandwiches", "Grilled vegetable dishes", "Baked goods", "Soup varieties", "Smoothie bowls", "Healthy snack options", "One-pot meals", "Casserole dishes", "Brunch items", "Quick stir-fries", "Frozen desserts", "Energy bites", "Sheet pan dinners", "Fruit salads", "Cold noodle dishes", "Barbecue sides", "Chilled soups", "Grain bowls", "Savory tarts", "Hot pot dishes", "Oven-roasted vegetables", "Finger foods"]

# DESCRIPTION
description_of_thematic_unit = ["Delicious desserts traditionally enjoyed during the Easter holiday.", "Creamy and flavorful rice dishes made with a variety of ingredients.", "Refreshing salads that are perfect for the hot summer months.", "Appetizers that are often served during holiday gatherings and parties.", "Nutritious and tasty smoothies perfect for a quick and healthy breakfast.", "Cold salads made with pasta and a variety of other ingredients.", "Sandwiches that are easy to pack and enjoy during a picnic.", "Vegetable dishes that are cooked on the grill for a delicious smoky flavor.", "Various baked treats such as cakes, cookies, and bread.", "Different types of soups, perfect for warming up on a chilly day.", "Thicker smoothies served in a bowl and topped with various fruits and nuts.", "Nutritious snacks that are both delicious and good for you.", "Meals that are cooked in a single pot for easy cleanup and convenience.", "Baked dishes made with a variety of ingredients, often topped with cheese or breadcrumbs.", "Dishes typically enjoyed during a late-morning meal combining breakfast and lunch.", "Fast and flavorful dishes made by quickly frying ingredients in a hot pan.", "Cold and sweet treats perfect for a hot day.", "Small, nutritious snacks packed with energy-boosting ingredients.", "Complete meals cooked on a single sheet pan in the oven.", "Colorful salads made with a variety of fresh fruits.", "Chilled noodle dishes often served with a flavorful sauce.", "Side dishes that complement grilled meats and vegetables.", "Soups that are served cold, ideal for hot summer days.", "Various dips and spreads served with bread, crackers, or vegetables.", "Nourishing bowls made with grains, vegetables, and protein.", "Delicious tarts filled with savory ingredients like cheese, vegetables, or meat.", "Comforting dishes cooked at the dining table in a simmering pot of broth.", "Vegetables roasted in the oven for a delicious caramelized flavor.", "Small, easy-to-eat foods that are perfect for parties and gatherings.", "Refreshing juice blends made from various fruits and vegetables."]

# IMAGE URL
image_of_thematic_unit = []
for _ in range(THEM_UNITS):
  url = f"https://dummyimage.com/{random.randint(1000,2000)}x{random.randint(1000,2000)}"
  image_of_thematic_unit.append(url)

# IMAGE DESCRIPTION
image_of_thematic_unit_desc = []
for _ in range(THEM_UNITS):
  image_of_thematic_unit_desc.append(data.sentence())
# -----------------------------------------------------------------------------------------------------




#--------------------------------------- BELONGS TO THEMATIC UNIT -------------------------------------
# RECIPE i BELONGS TO LIST OF THEMATIC UNITS
recipe_belongs_to_thematic_unit = []
for _ in range(RECIPES):
  recipe_belongs_to_thematic_unit.append([])

for i in range(RECIPES):
  recipe_belongs_to_thematic_unit[i] += random.sample(name_of_thematic_unit, random.randint(1, 7))
# -----------------------------------------------------------------------------------------------------




#------------------------------------------------ COOKS -----------------------------------------------
# ID  --  primary key
cook_id = []
for _ in range(COOKS):
  cook_id.append(data.unique.random_int(1, COOKS))

# NAME, SURNAME
name_of_cook = []
surname_of_cook = []
for _ in range(COOKS):
  full_name = (data.name()).split()
  name_of_cook.append(full_name[0])
  surname_of_cook.append(full_name[1])

# PHONE NUMBER
phone_number = []
for _ in range(COOKS):
  num = "69"
  for j in range(8):
    num += str(random.randint(0,9))
  phone_number.append(num)

# DATE OF BIRTH, YEARS OF EXPERIENCE
date_of_birth = []
years_of_experience = []
date1 = datetime(1960, 1, 1)
date2 = datetime(2005, 12, 12)
for _ in range(COOKS):
  b = data.date_between_dates(date1, date2)
  a = 2024 - b.year
  years_of_experience.append(random.randint(1, a - 18))
  date_of_birth.append(str(b))

# CATEGORY
categories = ['C Cook', 'B Cook', 'A Cook', "Chef's Assistant"]
cook_category = []
for _ in range(COOKS):
  cook_category.append(random.choice(categories))

chefs = random.sample(range(COOKS), 16)
for c in chefs:
  cook_category[c] = 'Chef'


# IMAGE URL
image_of_cook = []
for _ in range(INGREDIENTS):
  url = f"https://dummyimage.com/{random.randint(1000,2000)}x{random.randint(1000,2000)}"
  image_of_cook.append(url)

# IMAGE DESCRIPTION
image_of_cook_desc = []
for _ in range(COOKS):
  image_of_cook_desc.append(data.sentence())
# -----------------------------------------------------------------------------------------------------




#---------------------------------- COOK BELONGS TO NATIONAL CUISINE ----------------------------------
# COOK (with id - 1) i BELONGS TO LIST OF NATIONAL CUISINES
cooks_belongs_to_national_cuisine = []

for _ in range(COOKS):
  cooks_belongs_to_national_cuisine.append([])

for cuisine in existing_cuisines:
  cooks_to_assign = random.sample(cook_id, random.randint(3, 6))
  for cook in cooks_to_assign:
    cooks_belongs_to_national_cuisine[cook - 1].append(cuisine)

for cook in cooks_belongs_to_national_cuisine:
  if cook == []:
    cook += random.sample(existing_cuisines, random.randint(1, 3))
# -----------------------------------------------------------------------------------------------------



#------------------------------------------ FILE GENERATION -------------------------------------------

# food_group
data_insertions = "INSERT INTO food_group\nVALUES"
for i in range(FOOD_GROUPS):  
  data_insertions += f'\n    ("{name_of_food_group[i]}", "{description_of_food_group[i]}", "{recipe_description[i]}", "{image_of_food_group[i]}", "{image_of_food_group_desc[i]}")'
  if i < FOOD_GROUPS - 1:
    data_insertions += ','
  else:
    data_insertions += ';\n\n\n'

# ingredients
data_insertions += "INSERT INTO ingredients\nVALUES"
for i in range(INGREDIENTS):  
  data_insertions += f'\n    ("{name_of_ingredient[i]}", {calories_per_100gr[i]}, "{ingredient_of_food_group[i]}", "{image_of_ingredient[i]}", "{image_of_ingredient_desc[i]}")'
  if i < INGREDIENTS - 1:
    data_insertions += ','
  else:
    data_insertions += ';\n\n\n'

# recipe
data_insertions += "INSERT INTO recipe\nVALUES"
for i in range(RECIPES):  
  data_insertions += f'\n    ("{rec_name[i]}", "{rec_type[i]}", {level_of_diff[i]}, "{short_descr[i]}", {prep_time[i]}, {cooking_time[i]}, {portions[i]}, "{name_of_main_ingredient[i]}", {grams_of_fat_per_portion[i]}, {grams_of_carbohydrates_per_portion[i]}, {grams_of_proteins_per_portion[i]}, 0 ,"{recipe_belongs_to_national_cuisine[i]}", "{image_of_recipe[i]}", "{image_of_recipe_desc[i]}")'
  if i < RECIPES - 1:
    data_insertions += ','
  else:
    data_insertions += ';\n\n\n'

# needs_ingredient
data_insertions += "INSERT INTO needs_ingredient\nVALUES"
for i in range(RECIPES):
  rni = len(recipe_needs_ingredient[i])
  for j in range(rni):
    data_insertions += f'\n    ("{recipe_needs_ingredient[i][j][0]}", "{rec_name[i]}", {recipe_needs_ingredient[i][j][1]})'
    if i < RECIPES - 1 or j < rni - 1:
      data_insertions += ','
    else:
      data_insertions += ';\n\n\n'

# type_of_meal
data_insertions += "INSERT INTO type_of_meal\nVALUES"
for i in range(RECIPES):
  tom = len(recipe_has_meal_type[i])
  for j in range(tom):
    data_insertions += f'\n    ("{recipe_has_meal_type[i][j]}", "{rec_name[i]}")'
    if i < RECIPES - 1 or j < tom - 1:
      data_insertions += ','
    else:
      data_insertions += ';\n\n\n'

# tags
data_insertions += "INSERT INTO tags\nVALUES"
for i in range(RECIPES):
  rhtg = len(recipe_has_tag[i])
  for j in range(rhtg):
    data_insertions += f'\n    ("{recipe_has_tag[i][j]}", "{rec_name[i]}")'
    if i < RECIPES - 1 or j < rhtg - 1:
      data_insertions += ','
    else:
      data_insertions += ';\n\n\n'

# tips
data_insertions += "INSERT INTO tips\nVALUES"
for i in range(RECIPES):
  rhtp = len(recipe_has_tip[i])
  if rhtp == 0:
    if i == RECIPES - 1:
      new = data_insertions[:len(data_insertions) - 1]
      data_insertions = new + ';\n\n\n'
      # data_insertions += '\n\n\n'
      break
    else:
      continue
  for j in range(rhtp):
    data_insertions += f'\n    ("{rec_name[i]}", "{recipe_has_tip[i][j]}")'
    if i < RECIPES - 1 or j < rhtp - 1:
      data_insertions += ','
    else:
      data_insertions += ';\n\n\n'

# equipment
data_insertions += "INSERT INTO equipment\nVALUES"
for i in range(EQUIPMENT):  
  data_insertions += f'\n    ("{equipment_name[i]}", "{instruction_manual[i]}", "{image_of_equipment[i]}", "{image_of_equipment_desc[i]}")'
  if i < EQUIPMENT - 1:
    data_insertions += ','
  else:
    data_insertions += ';\n\n\n'

# uses_equipment
data_insertions += "INSERT INTO uses_equipment\nVALUES"
for i in range(RECIPES):
  rue = len(recipe_uses_equipment[i])
  for j in range(rue):
    data_insertions += f'\n    ("{rec_name[i]}", "{recipe_uses_equipment[i][j]}")'
    if i < RECIPES - 1 or j < rue - 1:
      data_insertions += ','
    else:
      data_insertions += ';\n\n\n'

# step
data_insertions += "INSERT INTO step\nVALUES"
for i in range(RECIPES):
  rfs = len(recipe_follows_steps[i])
  for j in range(rfs):
    data_insertions += f'\n    ("{recipe_follows_steps[i][j][1]}", {recipe_follows_steps[i][j][0]}, "{rec_name[i]}")'
    if i < RECIPES - 1 or j < rfs - 1:
      data_insertions += ','
    else:
      data_insertions += ';\n\n\n'

# thematic_unit
data_insertions += "INSERT INTO thematic_unit\nVALUES"
for i in range(THEM_UNITS):  
  data_insertions += f'\n    ("{name_of_thematic_unit[i]}", "{description_of_thematic_unit[i]}", "{image_of_thematic_unit[i]}", "{image_of_thematic_unit_desc[i]}")'
  if i < THEM_UNITS - 1:
    data_insertions += ','
  else:
    data_insertions += ';\n\n\n'

# belongs_to_thematic_unit
data_insertions += "INSERT INTO belongs_to_thematic_unit\nVALUES"
for i in range(RECIPES):
  rbttu = len(recipe_belongs_to_thematic_unit[i])
  for j in range(rbttu):
    data_insertions += f'\n    ("{rec_name[i]}", "{recipe_belongs_to_thematic_unit[i][j]}")'
    if i < RECIPES - 1 or j < rbttu - 1:
      data_insertions += ','
    else:
      data_insertions += ';\n\n\n'

# cooks
data_insertions += "INSERT INTO cooks\nVALUES"
for i in range(COOKS):  
  data_insertions += f'\n    ({cook_id[i]}, "{name_of_cook[i]}", "{surname_of_cook[i]}", "{phone_number[i]}", \'{date_of_birth[i]}\', NULL, {years_of_experience[i]}, "{cook_category[i]}", "{image_of_cook[i]}", "{image_of_cook_desc[i]}")'
  if i < COOKS - 1:
    data_insertions += ','
  else:
    data_insertions += ';\n\n\n'

# cook_belongs_to_national_cuisine
data_insertions += "INSERT INTO cooks_belongs_to_national_cuisine\nVALUES"
for i in range(COOKS):
  cbtnc = len(cooks_belongs_to_national_cuisine[i])
  for j in range(cbtnc):
    data_insertions += f'\n    ({cook_id[i]}, "{cooks_belongs_to_national_cuisine[i][j]}")'
    if i < COOKS - 1 or j < cbtnc - 1:
      data_insertions += ','
    else:
      data_insertions += ';\n\n\n'

data_insertions += 'INSERT INTO cook_credentials\n    VALUES (7, "Cook", "cook");'


filename = 'INSERTIONS_SMALL_16.sql'

with open(filename, 'w', encoding="utf-8") as script:
  script.write(data_insertions)
#-----------------------------------------------------------------------------------------------------



