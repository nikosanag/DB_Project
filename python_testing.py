import random
from faker import Faker
from faker_food import FoodProvider
from datetime import datetime
data = Faker()
data.add_provider(FoodProvider)

# x = "Once individual level way the ahead great. Fall more leave environmental hundred future relationship. People quality relationship investment well how play."
print(data.image_url())