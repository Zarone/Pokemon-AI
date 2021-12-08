# takes showdown pokedex database "pokedex.json" and outputs into smaller "new_pokedex.json"

import json

old_json = open("pokedex.json", "r")

old_json_data = json.load(old_json)

old_json.close()

new_json_data = {}

for key in old_json_data:
    pokemon = old_json_data[key]
    new_json_data[pokemon["name"]] = {"types": pokemon["types"], "baseStats": pokemon["baseStats"]}

new_json = open("new_pokedex.json", "w")
new_json.write(json.dumps(new_json_data))
new_json.close()