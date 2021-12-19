# takes showdown pokedex database "pokedex.json" and outputs into smaller "new_pokedex.json"

import json

old_json = open("pokedex.json", "r")

old_json_data = json.load(old_json)["Pokedex"]

old_json.close()

new_json_data = {}

for key in old_json_data:
    pokemon = old_json_data[key]
    new_json_data[pokemon["name"]] = {
        "types": pokemon["types"], "baseStats": pokemon["baseStats"]
    }
    if "otherFormes" in pokemon:
        new_json_data[pokemon["name"]]["otherFormes"] = pokemon["otherFormes"]

    if "cosmeticFormes" in pokemon:
        for form in pokemon["cosmeticFormes"]:
            new_json_data[form] = new_json_data[pokemon["name"]]

new_json_data["Urshifu-*"] = new_json_data["Urshifu"]

new_json = open("new_pokedex.json", "w")
new_json.write(json.dumps(new_json_data))
new_json.close()
