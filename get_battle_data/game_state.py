import json
from os import stat

def get_pokemon_data(pokemon):
    pokemon_raw = open("gamedata/pokedex.json", "r")
    pokemon_data = json.load(pokemon_raw)
    pokemon_raw.close()

    filter_name = pokemon.translate(
        dict((ord(char), None) for char in "â€™’")
    )

    pokemon_info = pokemon_data[filter_name]

    pokemon_info["HP%"] = 100
    pokemon_info["name"] = filter_name

    # for status: 0 is none, 1 is burn, 2 is freeze, 3 is paralysis, 4 is poison, 5 is badly poisoned, 6 is sleep
    pokemon_info["non-volatile-status"] = 0

    return pokemon_info

def get_types_array(typelist):
    types = [0 for _ in range(17)]

    if ("Bug" in typelist):
        types[0] = 1
    if ("Dark" in typelist):
        types[1] = 1
    if ("Dragon" in typelist):
        types[2] = 1
    if ("Electric" in typelist):
        types[3] = 1
    if ("Fighting" in typelist):
        types[4] = 1
    if ("Fire" in typelist):
        types[5] = 1
    if ("Flying" in typelist):
        types[6] = 1
    if ("Ghost" in typelist):
        types[7] = 1
    if ("Grass" in typelist):
        types[8] = 1
    if ("Ground" in typelist):
        types[9] = 1
    if ("Ice" in typelist):
        types[10] = 1
    if ("Normal" in typelist):
        types[11] = 1
    if ("Poison" in typelist):
        types[12] = 1
    if ("Psychic" in typelist):
        types[13] = 1
    if ("Rock" in typelist):
        types[14] = 1
    if ("Steel" in typelist):
        types[15] = 1
    if ("Water" in typelist):
        types[16] = 1
    
    return types

def get_status_array(status):
    status = [0 for _ in range(5)]

    if status == 1:
        status[0] = 1
    elif status == 2:
        status[1] = 1
    elif status == 3:
        status[2] = 1
    elif status == 4:
        status[3] = 1
    elif status == 5:
        status[3] = 2
    elif status == 6:
        status[4] = 1

    return status

def get_array(pokedata):
    hp = pokedata["HP%"]
    basestats = pokedata["baseStats"]
    types = get_types_array(pokedata["types"])
    status = get_status_array(pokedata["non-volatile-status"])
    
    return [hp, *[basestats[key] for key in basestats], *types, *status]

class GameState:
    def get_output(self):
        p1_active = None
        p1_bench = []
        p2_active = None
        p2_bench = []
        
        for i in range(6):
            if i == self.player1active:
                p1_active = get_array(self.player1team[i])
            else:
                for val in get_array(self.player1team[i]):
                    p1_bench.append(val)

            if i == self.player2active:
                p2_active = get_array(self.player2team[i])
            else:
                for val in get_array(self.player2team[i]):
                    p2_bench.append(val)


        return [ 
                [
                    self.numberofweatherturns,
                    *self.weathertype,
                    *self.player1hazards,
                    *self.player2hazards,
                    *self.player1volatilestatus,
                    *self.player2volatilestatus,
                    *self.player1boosts,
                    *self.player2boosts,
                    *p1_active, *p1_bench, *p2_active, *p2_bench
                 ], self.player1won
            ]
    def next_turn(self):
        for i in range(self.next_line, len(self.log)):
            if self.log[i].startswith("|turn"):
                if self.log[i].split("|")[2].strip() != str(self.current_turn):
                    self.next_line = i+1
                    break
            elif self.log[i].startswith("|switch"):
                player = 3
                if self.log[i].startswith("p1a", 8):
                    player = 1
                elif self.log[i].startswith("p2a", 8):
                    player = 2
                
                target_pokemon = self.log[i].split("|")[3].split(",")[0]

                if (player == 1):
                    for j in range(len(self.player1team)):
                        if self.player1team[j]["name"] == target_pokemon:
                            self.player1active = j
                            break
                elif (player == 2):
                    for j in range(len(self.player2team)):
                        if self.player2team[j]["name"] == target_pokemon:
                            self.player2active = j
                            break
            elif self.log[i].startswith("|-damage"):
                print("implement damage")
            elif self.log[i].startswith("|-heal"):
                print("implement heal")
            elif self.log[i].startswith("|-status"):
                print("implement status change")
            elif self.log[i].startswith("|-boost"):
                print("implement boost")
            elif self.log[i].startswith("|-unboost"):
                print("implement unboost")
            elif self.log[i].startswith("|-sidestart"):
                print("implement new field")
            elif self.log[i].startswith("|-sideend"):
                print("implement field move end")

        self.current_turn += 1

    def __init__(self, log_lines, debug=False):
        self.log = log_lines
        self.next_line = 0
        self.current_turn = 1
        self.player1name = log_lines[0].split("|j|☆")[1].strip()
        self.player2name = log_lines[1].split("|j|☆")[1].strip()
        self.player1team = []
        self.player2team = []
        self.player1won = None
        self.player1active = None
        self.player2active = None
        self.player1boosts = [0 for _ in range(5)]
        self.player2boosts = [0 for _ in range(5)]

        # right now these just check leech seed
        # but later I could add taunt, and other stuff like that
        self.player1volatilestatus = [0 for _ in range(1)] 
        self.player2volatilestatus = [0 for _ in range(1)]

        # spikes, toxic spikes, stealth rocks
        self.player1hazards = [0 for _ in range(3)]
        self.player2hazards = [0 for _ in range(3)]

        # weather: 0 => sun, 1 => rain, 2 => sand, 3 => hail
        self.numberofweatherturns = 0
        self.weathertype = [0 for _ in range(4)]

        turn_zero = False #there's a period when the game has started but there's no active

        if debug:
            print(self.player1name, self.player2name)

        for line in log_lines:
            self.next_line += 1
            if line.startswith("|poke"):
                split_player = None

                player = 3

                if line.startswith("p1", 6):
                    player = 1
                    split_player = line.split("p1|")[1]
                elif line.startswith("p2", 6):
                    player = 2
                    split_player = line.split("p2|")[1]

                split_gender = split_player.split(",")

                this_pokemon = None

                if len(split_gender) > 1:
                    this_pokemon = split_gender[0]
                else:
                    this_pokemon = split_player.split("|")[0]

                if (player == 1):
                    self.player1team.append(get_pokemon_data(this_pokemon))
                elif (player == 2):
                    self.player2team.append(get_pokemon_data(this_pokemon))
                else:
                    print("can't figure out what player it is")
            elif line.startswith("|win"):
                self.player1won = line.split("|win|")[1].strip() == self.player1name
            elif turn_zero and line.startswith("|switch"):
                player = 3
                if line.startswith("p1a", 8):
                    player = 1
                elif line.startswith("p2a", 8):
                    player = 2
                    turn_zero = False

                target_pokemon = line.split("|")[3].split(",")[0]

                if (player == 1):
                    for i in range(len(self.player1team)):
                        if self.player1team[i]["name"] == target_pokemon:
                            self.player1active = i
                            break
                elif (player == 2):
                    for i in range(len(self.player2team)):
                        if self.player2team[i]["name"] == target_pokemon:
                            self.player2active = i
                            break
                    break
            elif line.strip() == "|start":
                turn_zero = True
        
        if (debug):
            print(self.player1team)
            print(self.player2team)
        if debug:
            print(self.player1active, self.player2active)