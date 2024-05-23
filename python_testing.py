import random
from faker import Faker
from faker_food import FoodProvider
from datetime import datetime
data = Faker()
data.add_provider(FoodProvider)


name_of_thematic_unit = ["Thanksgiving desserts", "Christmas desserts", "Easter desserts", "Risotto dishes", "Summer salads", "Holiday appetizers", "Breakfast smoothies", "Pasta salads", "Picnic sandwiches", "Grilled vegetable dishes", "Baked goods", "Soup varieties", "Smoothie bowls", "Healthy snack options", "One-pot meals", "Casserole dishes", "Brunch items", "Quick stir-fries", "Frozen desserts", "Energy bites", "Sheet pan dinners", "Fruit salads", "Cold noodle dishes", "Barbecue sides", "Chilled soups", "Grain bowls", "Savory tarts", "Hot pot dishes", "Oven-roasted vegetables", "Finger foods"]
print(len(name_of_thematic_unit))