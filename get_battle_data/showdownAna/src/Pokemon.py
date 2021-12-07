#!/usr/bin/env python3

class Pokemon: 
    def __init__(self, name):
        """
        Initialise each pokemon with a name and base
        health of 100. TODO: add types!
        """
        self.name = name
        self.health = 100

    def change_health(self, new_health): 
        """
        Change the health of a pokemon
        to whatever it was at the end of the turn.
        This applies to both heals and damage.
        """
        self.health = new_health
