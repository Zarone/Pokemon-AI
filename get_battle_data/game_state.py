import json


def get_pokemon_data(pokemon):
    pokemon_raw = open("gamedata/pokedex.json", "r")
    pokemon_data = json.load(pokemon_raw)
    pokemon_raw.close()

    filter_name = pokemon.translate(
        dict((ord(char), None) for char in "â€™")
    )

    pokemon_info = pokemon_data[
        filter_name
    ]

    pokemon_info["name"] = filter_name

    return pokemon_info


class GameState:
    # def get_output(self):
    #     player_1_active = None
    #     player_1_bench = []
    #     player_2_active = None
    #     player_2_bench = []
        
    #     for pokemon in self.player1team:
    #         pass

    def __init__(self, log_lines, debug=False):
        self.player1name = log_lines[0].split("|j|â˜†")[1].strip()
        self.player2name = log_lines[1].split("|j|â˜†")[1].strip()
        self.player1team = []
        self.player2team = []
        self.player1won = None
        self.player1active = None
        self.player2active = None

        turn_zero = False #there's a period when the game has started but there's no active

        if debug:
            print(self.player1name, self.player2name)

        for line in log_lines:
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

            elif line.strip() == "|start":
                turn_zero = True
        if (debug):
            print(self.player1team)
            print(self.player2team)
        if debug:
            print(self.player1active, self.player2active)