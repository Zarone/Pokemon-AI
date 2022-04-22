import requests
import json

SEARCH_URL = "https://replay.pokemonshowdown.com/search.json?"
LOG_URL = "https://replay.pokemonshowdown.com/"
LOG_FOLDER = "unused_logs/"

def get_battle_ids(formats, pages_per_format): #50 battles per page
    id_list = []
    for format in formats:
      for i in range(pages_per_format):
        raw_json = json.loads(requests.get(SEARCH_URL+"format="+format+"&page="+str(i+1)).text)
        # id_list.append(raw_json[0]["id"])
        # id_list.append(raw_json[1]["id"])
        for element in raw_json:
          id_list.append(element["id"])
    return(id_list)

def get_raw_data_file(formats, pages_per_format):
  ids = get_battle_ids(formats, pages_per_format)
  print("got ids")
  for id in ids:
    data_file = open(LOG_FOLDER+id+".txt", "w", encoding="utf-8")
    raw_data = requests.get(LOG_URL+id+".log").text
    data_file.write(raw_data)
    data_file.close()
    print("finished id "+id)
  

'''
Getting a replay:

https://replay.pokemonshowdown.com/gen8doublesubers-1097585496.json

Search by format:

https://replay.pokemonshowdown.com/search.json?format=gen8ou

Paginate searches:

https://replay.pokemonshowdown.com/search.json?user=zarel&page=2
'''

get_raw_data_file(["gen5ou", "gen5uu", "gen5lc", "gen5nu"], 25)