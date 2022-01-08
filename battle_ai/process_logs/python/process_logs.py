'''

desired outputs:

  for each turn:
    an array like:
      [
        [

          # total length should be 409

          # weather (also tracks number of turns it's been out) (would add 5)
            # sun
            # rain
            # sand
            # hail

          # entry hazards (would add 9*2=18)
            # spikes
            # toxic spikes
            # stealth rocks
            # reflect
            # light screen
            # safeguard
            # mist
            # tailwind
            # lucky chant

          # status conditions ( would add 5*12+12*2 = 84 )
            # non-volatile ( for each pokemon )
              # burn
              # freeze
              # paralysis
              # poison (0 for no, 1 for yes, 2 for badly poisoned)
              # sleep
            # volatile
              # leech seed
              # Confused
              # Taunted
              # Yawning
              # Perish Song
              # Substitute
              # Focus Energy
              # Ingrain
              # disable
              # encore
              # futuresight
              # aquaring
              # attract
              # torment

          # stat boost array for each player (7*2)
          atk, spatk, def, spdef, spe, evasion, accuray

          # for each of you and your opponent's pokemon
          # make sure to include the active pokemon seperately
          
          # (1+6+17)*12 = 288
          %HP, *basestats, *types
          
          # 17 types
          # types = [ isFire, isWater, isGrass, etc ]

        ]

        won 
      ]

'''

import game_state as gs
import os

raw_log_dir = "../get_battle_data/raw_logs/"

def get_all_logs():
  for file in os.listdir(raw_log_dir):
      get_log(raw_log_dir+file)

def get_log(log_name):
  log = open(log_name, "r", encoding='utf-8', errors='ignore')
  new_game = gs.GameState(log.readlines(), False)
  for i in range(100):
    if (new_game.next_turn()): return
    # new_game.save_showdown_input()
    # print(i, len(new_game.get_output(1)[0]))
    # print("\n")
  log.close()

# get_all_logs()
get_log("last.txt")
# get_log("../get_battle_data/raw_logs/gen8nationaldex-1469587658.txt")
