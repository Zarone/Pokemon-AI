'''

desired outputs:

  for each turn:
    an array like:
      [
        [

          # to add:
            volatile status conditions or maybe entry hazards I don't know:
              Confused: volatile status
              Taunted: volatile status
              Yawning: volatile status
              Perish Song: volatile status
              Substitute: volatile status


          # total length should be 379

          # weather (also tracks number of turns it's been out) (would add 5)
            # sun
            # rain
            # sand
            # hail

          # entry hazards (would add 6*2=12)
            # spikes (up to 3)
            # stealth rocks
            # toxic spikes (up to 2)
            # reflect
            # lightscreen
            # tailwind

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
          atk, spatk, def, spdef, spe, evasion

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

raw_log_dir = "../get_battle_data/raw_logs/"

def get_all_logs():
  for file in os.listdir(raw_log_dir):
      get_log(raw_log_dir+file)

def get_log(log_name):
  log = open(log_name, "r", encoding='utf-8', errors='ignore')
  new_game = gs.GameState(log.readlines(), False)
  for i in range(50):
    if (new_game.next_turn()): return
    new_game.save_showdown_input()
    # print(i, new_game.get_output())
    # print("\n")
  log.close()

get_all_logs()
# get_log("last.txt")
# get_log("../get_battle_data/raw_logs/gen8nationaldex-1469587658.txt")