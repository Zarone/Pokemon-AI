#!/usr/bin/env python3
"""
TODO: If Increased performance needed, may convert string checks into regex
"""
def parse_turnline(in_line):
    #print(in_line)

    # Field updates
    if "|-weather|" in in_line:
        weather = in_line.split("|")[2]
        return ["weather_update", weather]
    if "|-fieldstart|" in in_line:
        field_string = in_line.split("|")[2].replace("move: ","").replace(" ","")
        return ["field_start", field_string]
    if "|-fieldend|" in in_line:
        field_string = in_line.split("|")[2].replace("move: ","").replace(" ","")
        return ["field_end", field_string]
    if "|-sidestart|p1" in in_line:
        side_string = in_line.split("|")[3].replace("move: ","").replace(" ","")
        return ["side_start", "Player1", side_string]
    if "|-sidestart|p2" in in_line:
        side_string = in_line.split("|")[3].replace("move: ","").replace(" ","")
        return ["side_start", "Player2", side_string]
    if "|-sideend|p1" in in_line:
        side_string = in_line.split("|")[3].replace("move: ","").replace(" ","")
        return ["side_end", "Player1", side_string]
    if "|-sideend|p2" in in_line:
        side_string = in_line.split("|")[3].replace("move: ","").replace(" ","")
        return ["side_end", "Player2", side_string]


    if "fail" in in_line or "Substitute" in in_line:
        return None
    if "message" in in_line and "forfeit" in in_line:
        print("Someone quit...")
        return None
    
    if "|p1a:" in in_line:
        player="Player1"
    elif "|p2a":
        player="Player2"
    else:
        return None

    if "switch" in in_line:
        switch_moves = ['U-turn', 'Volt Switch', 'Teleport', 'Baton Pass', 'Parting Shot', 'Flip Turn']
        if any(move in in_line for move in switch_moves):
            pokemon = in_line.split(": ")[-2].split("|")
        else:
            pokemon = in_line.split(": ")[-1].split("|")
        
        nickname = pokemon[0]
        original = pokemon[1].split(",")[0]
        if nickname != original:
            return ['switch_rename', player, original, nickname]
        else:
            return ['switch', player, original]

    if (("damage" not in in_line) and ("heal" not in in_line)):
        return None


    # Remove additional information from items etc..
    if "|[from]" in in_line:
        in_line = in_line.split("|[from]")[0]
    if "|[silent]" in in_line:
        in_line = in_line.split("|[silent]")[0]


    pokemon = in_line.split(": ")[-1].split("|")[0]

    hp_string = in_line.split("|")[-1]
    if "fnt" in hp_string:
        hp = 0
    elif "/" in hp_string:
        hp = int(hp_string.split("/")[0])
    else:
        hp = int(hp_string)

    return ["change_hp", player, pokemon, hp]


class ShowdownLog:
    def __init__(self, infile):
        
        with open(infile) as f:
            raw_lines = f.readlines()
        raw_lines = [line.rstrip() for line in raw_lines]
        
        # To avoid usernames overlapping with string comparisons, set them to default $PLAYER1$ and $PLAYER2$
        username1 = [line.split("|player|p1|")[-1].split("|")[0] for line in raw_lines if "|player|p1|" in line][0]
        username2 = [line.split("|player|p2|")[-1].split("|")[0] for line in raw_lines if "|player|p2|" in line][0]
        assert (username1 and username2)
        raw_lines = [l.replace(username1, "$PLAYER1$") for l in raw_lines]
        raw_lines = [l.replace(username2, "$PLAYER2$") for l in raw_lines]
        self.log_lines = raw_lines

        # Initial setting of variables, need to check for emptiness after initialising
        self.teampreview_indexlist = [i for i, line in enumerate(self.log_lines) if "|poke|p" in line]
        self.start_index = None
        self.win_index = None
        self.turn_indexlist = None
        self.nturns = 0

        start_indexlist = [i for i, line in enumerate(self.log_lines) if "|start" in line]
        win_indexlist = [i for i, line in enumerate(self.log_lines) if "|win|" in line]
        turn_indexlist = [i for i, line in enumerate(self.log_lines) if "|turn|" in line]

        if start_indexlist:
            self.start_index = [i for i, line in enumerate(self.log_lines) if "|start" in line][0]
        if win_indexlist:
            self.win_index = [i for i, line in enumerate(self.log_lines) if "|win|" in line][0]
        if turn_indexlist:
            self.turn_indexlist = [i for i, line in enumerate(self.log_lines) if "|turn|" in line]
            self.nturns = len(self.turn_indexlist)


    def print_indexvals(self):
        """ 
        Print of collected information 
        """
        print("TeamPreview Index List: {}".format(self.teampreview_indexlist))
        print("Start Index: {}".format(self.start_index))
        print("Turn Index List: {}".format(self.turn_indexlist))
        print("Win Index: {}".format(self.win_index))


    def get_initialteams(self):
        """ 
        Returns list of pokemon, Player1, Player2 
        Requires splitting 
        Logfile Line: 
            |poke|p1|Excadrill, M|
            |poke|p2|Ditto|
        """

        poke_lines = [self.log_lines[i] for i in self.teampreview_indexlist]
        team_player1 = [p.split("|p1|")[-1].split("|")[0].split(",")[0] for p in poke_lines if "p1" in p]
        team_player2 = [p.split("|p2|")[-1].split("|")[0].split(",")[0] for p in poke_lines if "p2" in p]

        return team_player1, team_player2


    def get_initialpokemon(self):
        """ 
        Returns Starting Pokemon for Player1 and Player2 
        |start
        |switch|p1a: Ferrothorn|Ferrothorn, M|100/100
        |switch|p2a: Shuckle|Shuckle, M|100/100
        |turn|1
        Should be the 2 lines between start_index and turn_indexlist[0]
        """

        poke_lines = [self.log_lines[i] for i in range(self.start_index, self.turn_indexlist[0]+1)]

        pokemon_player1 = [p.split("|")[3].split("|")[0].split(",")[0] for p in poke_lines if "|switch|p1a" in p][0]
        pokemon_player2 = [p.split("|")[3].split("|")[0].split(",")[0] for p in poke_lines if "|switch|p2a" in p][0]

        return pokemon_player1, pokemon_player2


    def get_turnlines(self,turn_number=1):
        """ 
        Returns all logfile lines for a given turn, in their original formatting
        """

        if turn_number < 0:
            return []
        if turn_number >= len(self.turn_indexlist):
            return []

        if turn_number == 0:
            turn_lines = [self.log_lines[i] for i in range(self.start_index, self.turn_indexlist[0])]
        else:
            turn_lines = [self.log_lines[i] for i in range(self.turn_indexlist[turn_number-1], self.turn_indexlist[turn_number])]
        
        return turn_lines

    def get_turn_actions(self,turn_number=1):
        """ 
        Returns all logfile lines for a given turn, in their original formatting
        """

        if turn_number < 0:
            return []
        if turn_number > self.nturns:
            return []
        
        if turn_number == 0:
            turn_lines = [self.log_lines[i] for i in range(self.start_index, self.turn_indexlist[0])]
        elif ((turn_number > 0) and (turn_number < self.nturns)):
            turn_lines = [self.log_lines[i] for i in range(self.turn_indexlist[turn_number-1], self.turn_indexlist[turn_number])]
        else:
            turn_lines = [self.log_lines[i] for i in range(self.turn_indexlist[turn_number-1], self.win_index)]

        actions = []
        for t in turn_lines:
            actions.append(parse_turnline(t))
        actions = [a for a in actions if a != None]
        
        return actions
