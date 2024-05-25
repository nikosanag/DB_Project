import random
from faker import Faker
from datetime import datetime
data = Faker()

YEARS = 5

image_of_episodes_per_year = []
for _ in range(YEARS):
  image_of_episodes_per_year.append([])

for i in range(YEARS):
  for _ in range(10):
    url = f"https://dummyimage.com/{random.randint(1000,2000)}x{random.randint(1000,2000)}"
    desc = data.sentence()
    append_value = (url, desc)
    image_of_episodes_per_year[i].append(append_value)


data_insertions = ''

for i in range(YEARS):
  for j in range(10):
    data_insertions += "UPDATE episodes_per_year\nSET "
    data_insertions += f'image_of_episode = "{image_of_episodes_per_year[i][j][0]}", image_of_episode_desc = "{image_of_episodes_per_year[i][j][1]}"\n'
    data_insertions += f'WHERE current_year = {i + 2020} AND episode_number = {j + 1};\n\n'

filename = 'EPISODES_IMAGES.sql'

with open(filename, 'w', encoding="utf-8") as script:
  script.write(data_insertions)