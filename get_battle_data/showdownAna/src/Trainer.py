#!/usr/bin/env python3

from src.Pokemon import Pokemon

class Trainer:
    def __init__(self, name, pokes):
        self.team = {}
        self.name = name
        
        if len(pokes) != 6: 
            raise AttributeError("There were", len(pokes), "on the team, not 6!!")

        for x in range(0, len(pokes)):
            self.team[pokes[x]] = Pokemon(pokes[x])

        # initialise the current pokemon as the first in the list
        # overwrite this before turn 1
        self.current = self.team[pokes[0]]    

    def __repr__(self):
        team = ",".join([x + "-" + str(self.team[x].health) for x in self.team])
        return "%s: %s (%i) Switched in: %s" % (self.name, team, len(self.team), self.current.name)


    def check_faints(self): 
        """
        At the end of each turn, check if any pokemon 
        have zero health. If they do remove them from 
        the (self.) team.
        """
        dead = [poke for poke in self.team if self.team[poke].health == 0]       
        for pokemon in dead:
            self.team.pop(pokemon)

    def set_current(self, pokemon):
        """
        Change the currently active pokemon.
        """
        self.current = pokemon


    def change_name(self, old_name, new_name): 
        """
        Some people are weird and rename their pokemon.
        The name is only updated when they are switched in
        so we need to change the name in our team.
        """
        # the nickname|original name comparison is done 
        # every time this poke is switched. if already
        # done, don't do again.
        if new_name in self.team.keys(): 
            return

        self.team[new_name] = self.team[old_name]
        self.team.pop(old_name)
