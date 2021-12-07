#!/usr/bin/env python3

"""
Tracks the status of the battle fields
Hazards for both players, Weather, Terrain

TODO: Track Player Substitutes
"""

PLAYER_HAZARDS_INT =  ["Spikes", "ToxicSpikes"]
PLAYER_HAZARDS_BOOL =  ["StealthRock", "StickyWeb"]
PLAYER_DEFENCES =  ["LightScreen", "Reflect", "Substitute"]

ALLOWED_WEATHER = ["none", "RainDance", "Sandstorm", "Hail", "SunnyDay"]
class Field: 
    def __init__(self): 
        self.field_conditions = {}

        # Variables that each player has
        for c in PLAYER_HAZARDS_INT:
            self.field_conditions["Player1_{}".format(c)] = 0
            self.field_conditions["Player2_{}".format(c)] = 0
        for c in PLAYER_HAZARDS_BOOL:
            self.field_conditions["Player1_{}".format(c)] = False
            self.field_conditions["Player2_{}".format(c)] = False
        for c in PLAYER_DEFENCES:
            self.field_conditions["Player1_{}".format(c)] = False
            self.field_conditions["Player2_{}".format(c)] = False
        
        # Variables that are global
        self.field_conditions["Weather"] = "none"
        self.field_conditions["Terrain"] = "none"
        self.field_conditions["TrickRoom"] = False
        self.field_conditions["Gravity"] = False

    def update_weather(self, weather):
        if weather in ALLOWED_WEATHER:
            self.field_conditions["Weather"] = weather
        else:
            print("{} not in current allowed list of {}".format(weather, ALLOWED_WEATHER))

    def update_global(self, condition, starting=True):
        """
        Method for updating the global field conditions such as terrain, trickroom, gravity
        """
        if starting:
            if "Terrain" in condition:
                self.field_conditions["Terrain"] = condition.replace("Terrain","")
            else:
               self.field_conditions[condition] = True 
        else:
            if "Terrain" in condition:
                self.field_conditions["Terrain"] = "none"
            else:
               self.field_conditions[condition] = False

    def update_side(self, player, condition, starting=True):
        side_condition = "{}_{}".format(player, condition)
        if starting:
            if condition in PLAYER_HAZARDS_INT:
                self.field_conditions[side_condition] += 1
            else:
                self.field_conditions[side_condition] = True
        else:
            if condition in PLAYER_HAZARDS_INT:
                self.field_conditions[side_condition] = 0
            else:
                self.field_conditions[side_condition] = False

    def __repr__(self):

        conditions_summary = "    FieldSummary    \n"
        conditions_summary += "--------------------\n"
        for c in PLAYER_HAZARDS_INT:
            conditions_summary+= "{}: Player1 {}, Player2 {}\n".format(c,self.field_conditions["Player1_{}".format(c)], self.field_conditions["Player2_{}".format(c)] )
        for c in PLAYER_HAZARDS_BOOL:
            conditions_summary+= "{}: Player1 {}, Player2 {}\n".format(c,self.field_conditions["Player1_{}".format(c)], self.field_conditions["Player2_{}".format(c)] )
        for c in PLAYER_DEFENCES:
            conditions_summary+= "{}: Player1 {}, Player2 {}\n".format(c,self.field_conditions["Player1_{}".format(c)], self.field_conditions["Player2_{}".format(c)] )

        conditions_summary += "--------------------\n"
        conditions_summary += "Weather: {}\n".format(self.field_conditions["Weather"])
        conditions_summary += "Terrain: {}\n".format(self.field_conditions["Terrain"])
        conditions_summary += "TrickRoom: {}\n".format(self.field_conditions["TrickRoom"])
        conditions_summary += "Gravity: {}\n".format(self.field_conditions["Gravity"])
        conditions_summary += "===================="

        return conditions_summary

if __name__ == '__main__':
    test_field = Field()
    print(test_field)


