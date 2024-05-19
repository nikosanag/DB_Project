import random
from faker import Faker
from faker_food import FoodProvider
data = Faker()
data.add_provider(FoodProvider)

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


print(random.randint(1, 2))