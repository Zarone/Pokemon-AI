'''

desired outputs:

  for each turn:
    a array like:
      [
        [
          Future Additions
            # info for both players
            stealth_rocks, sticky_webs, etc
            # status conditions

          # total length should be 298

          # stat boost array for each player
          atk, spatk, def, spdef, spe

          # for each of you and your opponent's pokemon
          # make sure to include the active pokemon seperately
          
          %HP, *basestats, *types
          
          # 17 types
          # types = [ isFire, isWater, isGrass, etc ]

        ]

        won 
      ]

'''

import game_state as gs
import os

for file in os.listdir("./raw_logs/"):
    log = open("raw_logs/"+file, "r")
    new_game = gs.GameState(log.readlines(), False)
    # print(len(new_game.get_output()[0]))
    new_game.next_turn()
    new_game.next_turn()
    new_game.next_turn()
    new_game.next_turn()
    log.close()
