import json
from os import stat

VOLATILE_CONDITIONS = 14
BOOSTS = 7
HAZARDS = 9

def get_pokemon_data(pokemon):
    pokemon_raw = open("../../pokedex/pokedex.json", "r")
    pokemon_data = json.load(pokemon_raw)
    pokemon_raw.close()

    filter_name = pokemon.translate(
        dict((ord(char), None) for char in "â€™’")
    )

    pokemon_info = pokemon_data[filter_name]

    pokemon_info["HP%"] = 100
    pokemon_info["name"] = filter_name

    # for status: 0 is none, 1 is burn, 2 is freeze, 3 is paralysis, 
    # 4 is poison, 5 is badly poisoned, 6 is sleep, 7 is faint
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
    status_arr = [0 for _ in range(6)]

    if status == 1: # burn
        status_arr[0] = 1
    elif status == 2: # freeze
        status_arr[1] = 1
    elif status == 3: # paralyze
        status_arr[2] = 1
    elif status == 4: # poison
        status_arr[3] = 1
    elif status == 5: # toxic
        status_arr[3] = 2
    elif status == 6: # sleep
        status_arr[4] = 1
    elif status == 7: # fainted
        status_arr[5] = 1

    return status_arr

def get_basestat_array(baseStats):
    return [baseStats["hp"], baseStats["atk"], baseStats["def"], baseStats["spa"], baseStats["spd"], baseStats["spe"]]

def get_array(pokedata):
    hp = pokedata["HP%"]
    basestats = get_basestat_array(pokedata["baseStats"])
    types = get_types_array(pokedata["types"])
    status = get_status_array(pokedata["non-volatile-status"])

    # [0, *[0, 0, 0, 0, 0, 0], *[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], *[0, 0, 0, 0, 0, 0]]
    # [100, 75, 75, 75, 130, 95, 130, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    return [hp, *basestats, *types, *status]


class GameState:
    def is_form_of(self, pokemon_form, pokemon_target):
        if pokemon_target == pokemon_form:
            return True
        pokemon_raw = open("../../pokedex/pokedex.json", "r")
        pokemon_data = json.load(pokemon_raw)
        pokemon_raw.close()

        filter_target_name = pokemon_target.translate(
            dict((ord(char), None) for char in "â€™’")
        )
        filter_form_name = pokemon_form.translate(
            dict((ord(char), None) for char in "â€™’")
        )

        if not filter_target_name in pokemon_data:
            filter_target_name = self.nickname_table[filter_target_name].translate(
                dict((ord(char), None) for char in "â€™’")
            )

        if filter_target_name == pokemon_form:
            return True

        if not "otherFormes" in pokemon_data[filter_target_name]:
            return False
        else:
            for form in pokemon_data[filter_target_name]["otherFormes"]:
                if form == filter_form_name:
                    return True
        return False

    def get_output(self, player): #player is either 1 or 2
        p1_active = None
        p1_bench = []
        p2_active = None
        p2_bench = []

        team1max = len(self.player1team) - 1
        team2max = len(self.player2team) - 1

        if team1max < 0 or team2max < 0:
            print("teams max: ", team1max, team2max)

        for i in range(6):
            if i > team1max:
                for val in [0, *[0, 0, 0, 0, 0, 0], *[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], *[0, 0, 0, 0, 0, 0]]:
                    p1_bench.append(val)
            else:
                if i == self.player1active:
                    p1_active = get_array(self.player1team[i])
                else:
                    for val in get_array(self.player1team[i]):
                        p1_bench.append(val)

            if i > team2max:
                for val in [0, *[0, 0, 0, 0, 0, 0], *[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], *[0, 0, 0, 0, 0, 0]]:
                    p2_bench.append(val)
            else:
                if i == self.player2active:
                    p2_active = get_array(self.player2team[i])
                else:
                    for val in get_array(self.player2team[i]):
                        p2_bench.append(val)

        # print(1)
        # print(len(self.weathertype))
        # print(len(self.player1hazards))
        # print(len(self.player2hazards))
        # print(len(self.player1volatilestatus))
        # print(len(self.player2volatilestatus))
        # print(len(self.player1boosts))
        # print(len(self.player2boosts))
        # print(len(p1_active))
        # print(len(p1_bench))
        # print(len(p2_active))
        # print(len(p2_bench))
        # print("\n\n\n")

        if p1_active == None:
            return None

        if player == 1:
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
        elif player == 2:
            return [
                [
                    self.numberofweatherturns,
                    *self.weathertype,
                    *self.player2hazards,
                    *self.player1hazards,
                    *self.player2volatilestatus,
                    *self.player1volatilestatus,
                    *self.player2boosts,
                    *self.player1boosts,
                    *p2_active, *p2_bench, *p1_active, *p1_bench
                ], not self.player1won
            ]
        else:
            print("player not specified")
            return []

    def in_between_turns(self):
        if self.player1volatilestatus[1] > 0:
            self.player1volatilestatus[1] -= 1
        if self.player1volatilestatus[2] > 0:
            self.player1volatilestatus[2] -= 1
        if self.player1volatilestatus[8] > 0:
            self.player1volatilestatus[8] -= 1
        if self.player1volatilestatus[9] > 0:
            self.player1volatilestatus[9] -= 1
        if self.player1volatilestatus[10] > 0:
            self.player1volatilestatus[10] -= 1
        if self.player2volatilestatus[1] > 0:
            self.player2volatilestatus[1] -= 1
        if self.player2volatilestatus[2] > 0:
            self.player2volatilestatus[2] -= 1
        if self.player2volatilestatus[8] > 0:
            self.player2volatilestatus[8] -= 1
        if self.player2volatilestatus[9] > 0:
            self.player2volatilestatus[9] -= 1
        if self.player2volatilestatus[10] > 0:
            self.player2volatilestatus[10] -= 1
        
    def next_turn(self):
        # returning true indicates that the game has not ended
        
        for i in range(self.next_line, len(self.log)):
            if self.log[i].startswith("|turn"):
                if self.log[i].split("|")[2].strip() != str(self.next_line):
                    self.next_line = i+1
                    if i == (len(self.log) - 1):
                        return False
                    else:
                        self.in_between_turns()
                        return True
            elif self.log[i].startswith("|switch") or self.log[i].startswith("|drag"):

                player = 3
                if self.log[i].startswith("p1a", 8):
                    player = 1                
                    self.player1boosts = [0 for _ in range(BOOSTS)]
                    self.player1volatilestatus = [0 for _ in range(VOLATILE_CONDITIONS)]
                elif self.log[i].startswith("p2a", 8):
                    player = 2
                    self.player2boosts = [0 for _ in range(BOOSTS)]
                    self.player2volatilestatus = [0 for _ in range(VOLATILE_CONDITIONS)]

                target_pokemon = self.log[i].split("|")[3].split(",")[0]

                nickname = self.log[i].split("|")[2].split(":")[1].translate(
                    dict((ord(char), None) for char in "â€™’")
                ).strip()
                self.nickname_table[nickname] = target_pokemon

                if (player == 1):
                    for j in range(len(self.player1team)):
                        if self.is_form_of(self.player1team[j]["name"], target_pokemon):
                            self.player1active = j
                            break
                elif (player == 2):
                    for j in range(len(self.player2team)):
                        if self.is_form_of(self.player2team[j]["name"], target_pokemon):
                            self.player2active = j
                            break
            elif self.log[i].startswith("|replace"):
                target_pokemon = self.log[i].split("|")[3].split(",")[0]

                nickname = self.log[i].split("|")[2].split(":")[1].translate(
                    dict((ord(char), None) for char in "â€™’")
                ).strip()
                self.nickname_table[nickname] = target_pokemon
            elif self.log[i].startswith("|-damage") or self.log[i].startswith("|-heal"):
                player = 3

                player_string = self.log[i].split("|")[2].split(":")[0]
                pokemon_string = self.log[i].split(
                    "|")[2].split(":")[1].strip()

                new_hp = ""
                before_slash = self.log[i].split("|")[3]
                if(before_slash.startswith("0")):
                    new_hp = "0"
                else:
                    new_hp = before_slash.split("/")[0].split("fnt")[0].rstrip()

                if player_string == "p1a":
                    player = 1
                elif player_string == "p2a":
                    player = 2
                else:
                    print("player not identified")

                if player == 1:
                    for p in range(len(self.player1team)):
                        if self.is_form_of(self.player1team[p]['name'], pokemon_string):
                            self.player1team[p]["HP%"] = int(new_hp)
                            if (int(new_hp) == 0):
                                self.player1team[p]["non-volatile-status"] = 7
                elif player == 2:
                    for p in range(len(self.player2team)):
                        if self.is_form_of(self.player2team[p]['name'], pokemon_string):
                            self.player2team[p]["HP%"] = int(new_hp)
                            if (int(new_hp) == 0):
                                self.player2team[p]["non-volatile-status"] = 7
            elif self.log[i].startswith("|-status"):
                info = self.log[i].split("|")
                condition = info[3].rstrip()
                pinfo = info[2]
                user_info = pinfo.split(":")[0]
                pokemon_string = pinfo.split(":")[1].strip()

                condition_int = 0

                if(condition == "brn"):
                    condition_int = 1
                elif condition == "frz":
                    condition_int = 2
                elif condition == "par":
                    condition_int == 3
                elif condition == "psn":
                    condition_int = 4
                elif condition == "tox":
                    condition_int = 5
                elif condition == "slp":
                    condition_int = 6
                else:
                    print("unhandled condition: ", condition)

                if(user_info == "p1a"):
                    for p in range(len(self.player1team)):
                        if (self.is_form_of(self.player1team[p]['name'], pokemon_string)):
                            self.player1team[p]["non-volatile-status"] = condition_int
                elif(user_info == "p2a"):
                    for p in range(len(self.player2team)):
                        if (self.is_form_of(self.player2team[p]['name'], pokemon_string)):
                            self.player2team[p]["non-volatile-status"] = condition_int
            elif self.log[i].startswith("|-boost"):
                split_line = self.log[i].split("|")
                player_string = split_line[2].split(":")[0]
                stat_string = split_line[3]
                stage_string = split_line[4].rstrip()

                stat_index = 7
                if stat_string == "atk":
                    stat_index = 0
                elif stat_string == "def":
                    stat_index = 1
                elif stat_string == "spa":
                    stat_index = 2
                elif stat_string == "spd":
                    stat_index = 3
                elif stat_string == "spe":
                    stat_index = 4
                elif stat_string == "accuracy":
                    stat_index = 5
                elif stat_string == "evasion":
                    stat_index = 6
                else:
                    print("stat not recognized: ", stat_string)

                if (player_string == "p1a"):
                    self.player1boosts[stat_index] += int(stage_string)
                elif (player_string == "p2a"):
                    self.player2boosts[stat_index] += int(stage_string)
            elif self.log[i].startswith("|-unboost"):
                split_line = self.log[i].split("|")
                player_string = split_line[2].split(":")[0]
                stat_string = split_line[3]
                stage_string = split_line[4].rstrip()

                stat_index = 7
                if stat_string == "atk":
                    stat_index = 0
                elif stat_string == "def":
                    stat_index = 1
                elif stat_string == "spa":
                    stat_index = 2
                elif stat_string == "spd":
                    stat_index = 3
                elif stat_string == "spe":
                    stat_index = 4
                elif stat_string == "accuracy":
                    stat_index = 5
                elif stat_string == "evasion":
                    stat_index = 6
                else:
                    print("stat not recognized: ", stat_string)

                if (player_string == "p1a"):
                    self.player1boosts[stat_index] -= int(stage_string)
                elif (player_string == "p2a"):
                    self.player2boosts[stat_index] -= int(stage_string)
            elif self.log[i].startswith("|-clearallboost"):
                self.player1boosts = [0 for _ in range(BOOSTS)]
                self.player2boosts = [0 for _ in range(BOOSTS)]
            elif self.log[i].startswith("|-sidestart"):
                split_line = self.log[i].split("|")
                move_split = split_line[3].split(":")
                player_string = split_line[2].split(":")[0]

                move_name = ""

                if len(move_split) == 1: 
                    move_name = move_split[0].strip()
                elif len(move_split) == 2:
                    move_name = move_split[1].strip()

                move_index = len(self.player1hazards)

                if move_name == "Spikes":
                    move_index = 0

                elif move_name == "Toxic Spikes":
                    move_index = 1

                elif move_name == "Stealth Rock":
                    move_index = 2

                elif move_name == "Reflect":
                    move_index = 3

                elif move_name == "Light Screen":
                    move_index = 4

                elif move_name == "Safeguard":
                    move_index = 5

                elif move_name == "Mist":
                    move_index = 6

                elif move_name == "Tailwind":
                    move_index = 7

                elif move_name == "Lucky Chant":
                    move_index = 8

                elif move_name == "Sticky Web":
                    move_index = 9

                elif move_name == "Aurora Veil":
                    move_index = 10

                else:

                    move_index = 11
                    print("couldn't find entry hazard: ", move_name)
                
                if move_index < 9:
                    if (player_string == "p1"):
                        if move_index == 0 and self.player1hazards[move_index] < 3:
                            self.player1hazards[move_index] += 1
                        elif move_index == 1 and self.player1hazards[move_index] < 2:
                            self.player1hazards[move_index] += 1
                        elif move_index == 2 and self.player1hazards[move_index] == 0:
                            self.player1hazards[move_index] = 1
                        elif move_index == 3 or move_index == 4 or move_index == 5 or move_index == 6 or move_index == 8:
                            self.player1hazards[move_index] = 5
                        elif move_index == 7:
                            self.player1hazards[move_index] = 4
                    elif (player_string == "p2"):
                        if move_index == 0 and self.player2hazards[move_index] < 3:
                            self.player2hazards[move_index] += 1
                        elif move_index == 1 and self.player2hazards[move_index] < 2:
                            self.player2hazards[move_index] += 1
                        elif move_index == 2 and self.player2hazards[move_index] == 0:
                            self.player2hazards[move_index] = 1
                        elif move_index == 3 or move_index == 4 or move_index == 5 or move_index == 6 or move_index == 8:
                            self.player2hazards[move_index] = 5
                        elif move_index == 7:
                            self.player2hazards[move_index] = 4
            elif self.log[i].startswith("|-sideend"):
                split_line = self.log[i].split("|")
                move_split = split_line[3].split(":")
                player_string = split_line[2].split(":")[0]

                move_name = ""

                if len(move_split) == 1: 
                    move_name = move_split[0].strip()
                elif len(move_split) == 2:
                    move_name = move_split[1].strip()

                move_index = len(self.player1hazards)

                if move_name == "Spikes":
                    move_index = 0

                elif move_name == "Toxic Spikes":
                    move_index = 1

                elif move_name == "Stealth Rock":
                    move_index = 2

                elif move_name == "Reflect":
                    move_index = 3

                elif move_name == "Light Screen":
                    move_index = 4

                elif move_name == "Safeguard":
                    move_index = 5

                elif move_name == "Mist":
                    move_index = 6

                elif move_name == "Tailwind":
                    move_index = 7

                elif move_name == "Lucky Chant":
                    move_index = 8

                elif move_name == "Sticky Web":
                    move_index = 9

                elif move_name == "Aurora Veil":
                    move_index = 10

                else:
                    move_index = 11
                    print("couldn't find entry hazard: ", move_name)
                
                if move_index < 9:
                    if (player_string == "p1"):
                        self.player1hazards[move_index] = 0    
                    elif (player_string == "p2"):
                        self.player2hazards[move_index] = 0    
            elif self.log[i].startswith("|-curestatus"):
                info = self.log[i].split("|")
                pinfo = info[2]
                user_info = pinfo.split(":")[0]
                pokemon_string = pinfo.split(":")[1].strip()
                if(user_info == "p1a"):
                    for p in range(len(self.player1team)):
                        if (self.is_form_of(self.player1team[p]['name'], pokemon_string)):
                            self.player1team[p]["non-volatile-status"] = 0
                elif(user_info == "p2a"):
                    for p in range(len(self.player2team)):
                        if (self.is_form_of(self.player2team[p]['name'], pokemon_string)):
                            self.player2team[p]["non-volatile-status"] = 0
            elif self.log[i].startswith("|-weather"):
                log_split = self.log[i].split('|')
                weather_type = log_split[2].strip()

                if (len(log_split) < 4 or log_split[3].startswith("[from]")): # that means that it's a trigger
                    self.numberofweatherturns = 5
                    if weather_type == "SunnyDay":
                        self.weathertype = [1, 0, 0, 0]
                    elif weather_type == "RainDance":
                        self.weathertype = [0, 1, 0, 0]
                    elif weather_type == "Sandstorm":
                        self.weathertype = [0, 0, 1, 0]
                    elif weather_type == "Hail":
                        self.weathertype = [0, 0, 0, 1]
                    elif weather_type == "none":
                        self.weathertype = [0, 0, 0, 0]
                    else:
                        print("unknown weather condition: ", weather_type)
                elif log_split[3].startswith("[upkeep]"):
                    if self.numberofweatherturns > 0:
                        self.numberofweatherturns-=1
            elif self.log[i].startswith("|-start"):
                log_split = self.log[i].split("|")
                player_string = log_split[2].split(":")[0].lstrip()
                effect_string = log_split[3].split(":")

                if len(effect_string) > 1:
                    effect_string = effect_string[1].strip()
                else:
                    effect_string = effect_string[0].strip()

                effect_int = None
                effect_value = -1

                if effect_string == "Leech Seed":
                    effect_int = 0
                    effect_value = 1
                elif effect_string == "confusion":
                    effect_int = 1
                    effect_value = 5
                elif effect_string == "Taunt":
                    effect_int = 2
                    effect_value = 3
                elif effect_string == "Yawn":
                    effect_int = 3
                    effect_value = 1
                elif effect_string == "perish3":
                    effect_int = 4
                    effect_value = 1
                elif effect_string == "perish2":
                    effect_int = 4
                    effect_value = 2
                elif effect_string == "perish1":
                    effect_int = 4
                    effect_value = 3
                elif effect_string == "perish0":
                    effect_int = 4
                    effect_value = 0
                elif effect_string == "Substitute":
                    effect_int = 5
                    effect_value = 1
                elif effect_string == "Focus Energy":
                    effect_int = 6
                    effect_value = 1
                elif effect_string == "Ingrain":
                    effect_int = 7
                    effect_value = 1
                elif effect_string == "Disable":
                    effect_int = 8
                    effect_value = 4
                elif effect_string == "Encore":
                    effect_int = 9
                    effect_value = 3
                elif effect_string == "Future Sight":
                    effect_int = 10
                    effect_value = 3
                elif effect_string == "Aqua Ring":
                    effect_int = 11
                    effect_value = 1
                elif effect_string == "Attract":
                    effect_int = 12
                    effect_value = 1
                elif effect_string == "Torment":
                    effect_int = 13
                    effect_value = 1
                elif effect_string == "Autotomize":
                    effect_int = 14
                    effect_value = 1
                elif effect_string == "typechange":
                    effect_int = 15
                    effect_value = 1
                elif effect_string == "Imprison":
                    effect_int = 16
                    effect_value = 1
                elif effect_string == "Magnet Rise":
                    effect_int = 17
                    effect_value = 1
                elif effect_string == "Flash Fire":
                    effect_int = 18
                    effect_value = 1
                elif effect_string == "Foresight":
                    effect_int = 19
                    effect_value = 1
                elif effect_string == "stockpile1":
                    effect_int = 20
                    effect_value = 1
                elif effect_string == "stockpile2":
                    effect_int = 21
                    effect_value = 1
                elif effect_string == "stockpile3":
                    effect_int = 22
                    effect_value = 1
                else:
                    effect_int = 100
                    print("effect not handled properly: ", effect_string)
                
                if effect_int < len(self.player1volatilestatus):
                    if player_string.startswith("p1a"):
                        self.player1volatilestatus[effect_int] = effect_value
                    elif player_string.startswith("p2a"):
                        self.player2volatilestatus[effect_int] = effect_value
                    else:
                        print("player not found: ", player_string)
            elif self.log[i].startswith("|win") or self.log[i].startswith("|tie|"):
                return False

        return True

    def __init__(self, log_lines, debug=False):
        self.log = log_lines
        self.next_line = 0
        self.player1name = None
        self.player2name = None
        self.player1team = []
        self.player2team = []
        self.player1won = None
        self.player1active = None
        self.player2active = None
        # atk, def, spa, spd, spe, accuracy, evasion
        self.player1boosts = [0 for _ in range(BOOSTS)]
        self.player2boosts = [0 for _ in range(BOOSTS)]
        self.nickname_table = {}

        # leechseed, confused, taunt, yawn, perishsong, substitute, Focus Energy, 
        # Ingrain, typechange, disable, encore, futuresight, autotomize, aquaring
        self.player1volatilestatus = [0 for _ in range(VOLATILE_CONDITIONS)]
        self.player2volatilestatus = [0 for _ in range(VOLATILE_CONDITIONS)]

        # spikes, toxic spikes, stealth rocks, reflect, lightscreen, tailwind
        self.player1hazards = [0 for _ in range(HAZARDS)]
        self.player2hazards = [0 for _ in range(HAZARDS)]

        self.numberofweatherturns = 0
        # weather: 0 => sun, 1 => rain, 2 => sand, 3 => hail
        self.weathertype = [0 for _ in range(4)]

        turn_zero = False  # there's a period when the game has started but there's no active

        if debug:
            print(self.player1name, self.player2name)

        for line in log_lines:
            self.next_line += 1
            if line.startswith("|player"):
                if(line.split("|")[2] == "p1"):
                    this_split = line.split("|")
                    if len(this_split) > 3:
                        self.player1name = this_split[3]
                elif(line.split("|")[2] == "p2"):
                    this_split = line.split("|")
                    if len(this_split) > 3:
                        self.player2name = this_split[3]
            elif line.startswith("|poke"):
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
                self.player1won = line.split(
                    "|win|")[1].strip() == self.player1name
            elif turn_zero and line.startswith("|switch"):
                player = 3
                if line.startswith("p1a", 8):
                    player = 1
                elif line.startswith("p2a", 8):
                    player = 2
                    turn_zero = False

                target_pokemon = line.split("|")[3].split(",")[0]

                nickname = line.split("|")[2].split(":")[1].lstrip()
                self.nickname_table[nickname] = target_pokemon

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
                    # break
                    turn_zero = False
            elif line.strip() == "|start":
                turn_zero = True

        self.next_line = 1

        if (debug):
            print(self.player1team)
            print(self.player2team)
        if debug:
            print(self.player1active, self.player2active)