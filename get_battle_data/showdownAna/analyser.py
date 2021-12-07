#!/usr/bin/env python3

from src.ShowdownLog import ShowdownLog
from src.Trainer import Trainer
from src.Field import Field
from src.Battle import Battle
import glob

def play_log(logfile):

    #print(logfile)
    dummy_log = ShowdownLog(logfile)
    # read in the intial team lists for players 1 and 2
    team1, team2 = dummy_log.get_initialteams()
    # initialise each player with their respective teams
    player1 = Trainer("Player1", team1)
    player2 = Trainer("Player2", team2)
    field = Field()
    # initialise the battle
    battle = Battle(player1, player2, field)
    #loop over all turns and process them
    for i in range(0, dummy_log.nturns+1):
        
        actions_this_turn = dummy_log.get_turn_actions(i)
        battle.process_turn(actions_this_turn)

        #print(battle.field)

        #print("########### Turn", i, "###########")
        #print("", repr(player1), "\n", repr(player2))
    #if len(player1.team) == 0: 
    #    print("Player 2 won!")
    #elif len(player2.team) == 0: 
    #    print("Player 1 won!")
    #else: 
    #    print(len(player1.team), len(player2.team))



def main():
    test_files = glob.glob("example_logs/*.txt")[:1]
    for logfile in test_files:
        try:
            play_log(logfile)
        except:
            pass

    play_log("example_logs/1039998119.txt")

if __name__ == "__main__":
    main()
