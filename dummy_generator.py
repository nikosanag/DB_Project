import mysql.connector
import random
from faker import Faker
from faker_food import FoodProvider
data = Faker()
data.add_provider(FoodProvider)


INGREDIENTS = 300
FOOD_GROUPS = 12
COOKS = 500



#--------------------------------------------- FOOD GROUP ---------------------------------------------
# NAME
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
for i in range (11):
  description_of_food_group.append(data.unique.sentence())

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
# -----------------------------------------------------------------------------------------------------




#-------------------------------------------- INGREDIENTS ---------------------------------------------
# NAME
name_of_ingredient = []
for i in range(INGREDIENTS - 1):
  name_of_ingredient.append(data.unique.ingredient())

# CALORIES PER 100g
calories_per_100gr = []
for i in range(INGREDIENTS - 1):
  calories_per_100gr.append(random.randint(15, 650))

# -----------------------------------------------------------------------------------------------------




db = mysql.connector.connect(
  host = "localhost",
  user = "root",
  passwd = "MySQLmasterchef24ecentu@"
)

cursor = db.cursor()
cursor.execute("DROP DATABASE IF EXISTS `cooking`")
cursor.execute("CREATE DATABASE `cooking`")
cursor.execute("USE `cooking`")

# cursor.execute("SHOW DATABASES")

# for database in cursor:
#   print(database)



