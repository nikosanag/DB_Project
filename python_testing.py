import random
from faker import Faker
from faker_food import FoodProvider
from datetime import datetime
data = Faker()
data.add_provider(FoodProvider)



recipe_belongs_to_national_cuisine = []
all_national_cuisines = []
for _ in range(118):
  all_national_cuisines.append(data.unique.ethnic_category())

x = list(set(all_national_cuisines))

