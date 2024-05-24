import random
from faker import Faker
from faker_food import FoodProvider
from datetime import datetime
data = Faker()
data.add_provider(FoodProvider)


national_cuisine = []

for _ in range(118):
  x = data.unique.ethnic_category()
  national_cuisine.append(x)

for i in range(len(national_cuisine)):
  print(national_cuisine[i])