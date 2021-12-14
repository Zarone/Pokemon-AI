'''

desired outputs:

  for each turn:
    a array like:
      [
        [

          # total length should be 371

          # weather (also tracks number of turns it's been out) (would add 5)
            # sun
            # rain
            # sand
            # hail

          # entry hazards (would add 3*2=6)
            # spikes (up to 3)
            # stealth rocks
            # toxic spikes (up to 2)

          # status conditions ( would add 5*12+1*2 = 62 )
            # non-volatile ( for each pokemon )
              # burn
              # freeze
              # paralysis
              # poison (0 for no, 1 for yes, 2 for badly poisoned)
              # sleep
            # volatile
              # leech seed

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
    new_game.next_turn()
    # new_game.next_turn()
    # new_game.next_turn()
    log.close()

# log = open("raw_logs/gen8nationaldex-1469658534.txt", "r")
# new_game = gs.GameState(log.readlines(), False)
# print(len(new_game.get_output()[0]))
# new_game.next_turn()
# new_game.next_turn()
# new_game.next_turn()
# new_game.next_turn()
# new_game.next_turn()
# new_game.next_turn()
# new_game.next_turn()
# new_game.next_turn()
# log.close()