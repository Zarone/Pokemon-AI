'''

desired outputs:

  for each turn:
    a json like:
      {

        stat boost array for each player
        statboosts: [ atk, spatk, def, spdef, spe ]

        for each of you and your opponent's pokemon
        ownteam / opponent's team: { [types], %HP, [basestats] },
        17 types
        [ isFire, isWater, isGrass, etc ]

        make sure to include the active pokemon seperately

        won 
      }

'''

import game_state as gs
import os

for file in os.listdir("./raw_logs/"):
    log = open("raw_logs/"+file, "r")
    new_game = gs.GameState(log.readlines(), False)
    log.close()
