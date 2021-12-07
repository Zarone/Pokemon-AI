'''

desired outputs:

  for each turn:
    a json like:
      { 
        maybe:
          turns of rain
          turns of hail
          turns of sun
          turns of sand

        stat boost array for each player
        [ atk, spatk, def, spdef, spe ]


        for each of you and your opponent's pokemon
        { type, %HP },
      
        type is either going to be stored as 
        [ type1, type2 ]
        where the types are unique integers

        or I suspect a model like this may learn better
        17 types
        [ isFire, isWater, isGrass, etc ]

        try the first way first, then the other way
        if the first way works, try inserting more data

        won 
      }

'''

import game_state.game_state as gs
import os

for file in os.listdir("./raw_logs/"):
  log = open("raw_logs/"+file, "r")
  new_game = gs.GameState(log.readlines())
  log.close()