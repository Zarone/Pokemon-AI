'''

desired outputs:

  for each turn:
    an array like:
      [
        [

          # total length should be 425

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

          # status conditions ( would add 6*12+14*2 = 100 )
            # non-volatile ( for each pokemon )
              # burn
              # freeze
              # paralysis
              # poison (0 for no, 1 for yes, 2 for badly poisoned)
              # sleep
              # fainted
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
          %HP, *stats (or basestats), *types
          
          # 17 types
          # types = [ isFire, isWater, isGrass, etc ]

        ]

        won 
      ]

'''

import game_state as gs
import os
import msgpack

raw_log_dir = "../../../get_battle_data/raw_logs/"

def get_all_logs():
  process_files = 0
  for file in os.listdir(raw_log_dir):
      if file != ".DS_Store":
        print(file)
        process_files+=1
        print(process_files)
        get_log(raw_log_dir+file, file)

def get_log(log_name, file):
  log = open(log_name, "r", encoding='utf-8', errors='ignore')
  new_game = gs.GameState(log.readlines(), False)
  if len(new_game.player1team) < 1 or len(new_game.player2team) < 1:
    print(file, "- null team")
    return False
  maxTurns = 100
  for i in range(maxTurns):
    if (new_game.next_turn()):
      outputFile = open('../../state_files/processed_logs/'+file+"-"+str(i), 'wb')
      output = new_game.get_output(1)
      outputFile.write(msgpack.packb(output))
      outputFile.close()
      
      # return
    # print(str(i)+" out of "+str(maxTurns))
    # print(i, len(new_game.get_output(1)[0]))
    # print("\n")
  # log.close()
  # new_game.next_turn()
  # new_game.next_turn()

get_all_logs()
# get_log("last.txt")
# get_log("../../../get_battle_data/raw_logs/gen8nationaldex-1469587658.txt", "gen8nationaldex-1469587658.txt")
