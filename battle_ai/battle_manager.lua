using_test_data = false
debug_data = true

debug_state = {{255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 100, 24, 11, 10, 11, 11, 13, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1, 100, 17, 10, 8, 7, 8, 8, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, 0, 0, 0, 0, 0, 1}, 'N/A_s', 0, 0, '', '', '', '', 0, 0}
debug_team1 = "Tepig||none|Blaze|tackle,tailwhip,,|Timid|0,0,0,1,0,1||4,23,3,19,16,29||6|79,,"
debug_team2 = "Patrat||none|Keen Eye|tackle,leer,,|Careful|0,0,0,0,0,0||1,16,9,8,4,15||4|70,,"

params = {...}
if params[1] == "debug" then
    using_test_data = true
end

json = require "lunajson"

Writer = require "./battle_ai/showdown_writer"
PokeReader = nil
StateReader = nil
GameReader = nil
if not using_test_data then
    PokeReader = require "./battle_ai/ram_reader/gen5_pokemonreader"
    StateReader = require "./battle_ai/ram_reader/gen5_statereader"
    GameReader = require "./battle_ai/ram_reader/gen5_logreader"
end

package.cpath = ";./battle_ai/backprop_ai/build/?.so"
processor = require "processor"

BattleManager = {}
BattleManager.__index = BattleManager

function BattleManager.get_teams(IGReader, is_wild)

    team1 = IGReader:get(1)

    team2 = nil
    if is_wild then
        team2 = IGReader:get(5)
    else
        team2 = IGReader:get(2)
    end
    
    return team1, team2
end

function BattleManager.get_teams_packed(IGReader, is_wild)
    team1 = IGReader:get(1)
    str_team1 = Writer.to_packed_team(team1)

    team2 = nil
    if is_wild then
        team2 = IGReader:get(5)
    else
        team2 = IGReader:get(2)
    end

    str_team2 = Writer.to_packed_team(team2)
    
    return str_team1, str_team2
end

function BattleManager.new()

    instance_IGReader = nil
    if (not using_test_data) then
        instance_IGReader = PokeReader.new(4, 5)        
    end
    
    
    if (not using_test_data) then
        local wild_battle = not not (GameReader.line_text():find("A wild"))
        if wild_battle then print("is wild battle") end
        team1, team2 = BattleManager.get_teams(instance_IGReader, wild_battle)
    else
        team1 = {
            {nickname='Freeza', ability='Pressure', nature='Modest', happiness=70, evs={0, 0, 0, 0, 0, 0}, name='Mewtwo', item='none', ivs={7, 16, 30, 13, 12, 5}, level=70, moves={'Psycho Cut', 'Disable', 'Future Sight', 'Guard Swap'}},
            {nickname='Diamond', ability='Sturdy', nature='Docile', happiness=72, evs={0, 0, 0, 0, 0, 0}, name='Crustle', item='none', ivs={20, 0, 7, 16, 26, 20}, level=35, moves={'Bug Bite', 'Stealth Rock', 'Rock Slide', 'Slash'}},
            {nickname='Nidoqueen', ability='Poison Point', nature='Sassy', happiness=76, evs={85, 85, 85, 85, 85, 85}, name='Nidoqueen', item='none', ivs={31, 31, 31, 31, 31, 31}, level=100, moves={'Toxic Spikes', 'Superpower', 'Earth Power', 'Fury Swipes'}},
            {nickname='Spaiky', ability='Swift Swim', nature='Quirky', happiness=72, evs={0, 0, 0, 0, 0, 0}, name='Qwilfish', item='Focus Sash', ivs={15, 9, 22, 12, 18, 14}, level=47, moves={'Spikes', 'Pin Missile', 'Take Down', 'Aqua Tail'}},
            {nickname='Hydreigon', ability='Levitate', nature='Timid', happiness=255, evs={6, 0, 0, 252, 0, 252}, name='Hydreigon', item='Choice Specs', ivs={31, 31, 31, 31, 31, 31}, level=100, moves={'Draco Meteor', 'Fly', 'Dark Pulse', 'Focus Blast'}},
            {nickname='Blaziken', ability='Speed Boost', nature='Adamant', happiness=255, evs={4, 252, 0, 0, 0, 252}, name='Blaziken', item='Leftovers', ivs={31, 31, 31, 24, 31, 31}, level=77, moves={'High Jump Kick', 'Rock Slide', 'Protect', 'Flare Blitz'}}
        }
            
        team2 = {
            {nickname='Cofagrigus', ability='Mummy', nature='Sassy', happiness=255, evs={0, 0, 0, 0, 0, 0}, name='Cofagrigus', item='none', ivs={30, 30, 30, 30, 30, 30}, level=71, moves={'Shadow Ball', 'Psychic', 'Will-O-Wisp', 'Energy Ball'}},
            {nickname='Jellicent', ability='Cursed Body', nature='Careful', happiness=255, evs={0, 0, 0, 0, 0, 0}, name='Jellicent', item='none', ivs={30, 30, 30, 30, 30, 30}, level=71, moves={'Shadow Ball', 'Psychic', 'Hydro Pump', 'Sludge Wave'}},
            {nickname='Froslass', ability='Snow Cloak', nature='Impish', happiness=255, evs={0, 0, 0, 0, 0, 0}, name='Froslass', item='none', ivs={30, 30, 30, 30, 30, 30}, level=71, moves={'Shadow Ball', 'Psychic', 'Blizzard', 'Ice Shard'}},
            {nickname='Drifblim', ability='Aftermath', nature='Quirky', happiness=255, evs={0, 0, 0, 0, 0, 0}, name='Drifblim', item='none', ivs={30, 30, 30, 30, 30, 30}, level=71, moves={'Shadow Ball', 'Psychic', 'Acrobatics', 'Thunder'}},
            {nickname='Golurk', ability='Iron Fist', nature='Jolly', happiness=255, evs={0, 0, 0, 0, 0, 0}, name='Golurk', item='none', ivs={30, 30, 30, 30, 30, 30}, level=71, moves={'Shadow Punch', 'Earthquake', 'Hammer Arm', 'Curse'}},
            {nickname='Chandelure', ability='Flame Body', nature='Calm', happiness=255, evs={0, 0, 0, 0, 0, 0}, name='Chandelure', item='none', ivs={30, 30, 30, 30, 30, 30}, level=73, moves={'Shadow Ball', 'Psychic', 'Fire Blast', 'Payback'}}
        }
    end

    names = {}
    names_enemy = {}
    
    for i, v in pairs(team1) do
        table.insert(names, v.nickname)
    end
    for i, v in pairs(team2) do
        table.insert(names_enemy, v.nickname)
    end

    instance_game_reader = nil
    if not using_test_data then
        instance_game_reader = GameReader.new(names, names_enemy, StateReader.get_player_health(#instance_IGReader:get(1)))
    end

    instance = setmetatable({
        game_reader = instance_game_reader,
        IGReader = instance_IGReader,
        showdown_instance = nil,
        queued_move = nil,
        queued_switch = nil
    }, BattleManager)
    return instance
end

function BattleManager.act_catch(self)
    if self.game_reader:get_line() then
        self.queued_switch = nil
        return self:act_open_catch()
    else
        self:act_close()
    end

    -- either 0 for no action, 1 for moveslot 1... 4 for moveslot 4, 5 for switch to party slot 1, 10 for party slot 6 
end

function BattleManager:act_open_catch()
    if self.queued_move == nil then
        -- if not using_test_data then
            -- self:saveState()
        -- end

        team1 = nil
        team2 = nil
        
        if not using_test_data then
            team1, team2 = BattleManager.get_teams_packed(self.IGReader)
            if debug_data then print("team1", team1, "team2", team2) end
            -- print(team1, team2)
        else
            team1 = debug_team1
            team2 = debug_team1
        end

        Writer.saveTeams(team1, team2)
        self:get_action_catch()
        print(self.queued_move.move)
        return {move = 0}
    end 
    return self.queued_move
end

function BattleManager.act(self)
    if self.game_reader:get_line() then
        self.queued_switch = nil
        return self:act_open()
    else
        self:act_close()
    end

    -- either 0 for no action, 1 for moveslot 1... 4 for moveslot 4, 5 for switch to party slot 1, 10 for party slot 6 
end

function BattleManager:act_open()
    if self.queued_move == nil then
        -- if not using_test_data then
            -- self:saveState()
        -- end

        team1 = nil
        team2 = nil

        if not using_test_data then
            team1, team2 = BattleManager.get_teams_packed(self.IGReader)
            if debug_data then print("team1", team1, "team2", team2) end
            -- print(team1, team2)
        else
            team1 = "Tepig||none|Blaze|tackle,tailwhip,,|Timid|0,0,0,0,0,0||4,23,3,19,16,29||5|70,," 
            team2 = "Snivy||none|Overgrow|tackle,leer,,|Bold|0,0,0,0,0,0||0,0,0,0,0,0||5|255,,"
        end
        Writer.saveTeams(team1, team2)
        self:get_action()
        return {move = 0}
    end 
    return self.queued_move
end

function BattleManager:act_close()
    if self.queued_move ~= nil then
        print("BattleManager:act_close(), user can't attack")
        self.queued_move = nil
    end
    return 0
end

-- this function is only meant to be called by C
function frame()
    if not using_test_data then
        emu.frameadvance()
    end
    -- print("Skipping Frame")
end

function exec_showdown_state(state, activeP1, activeP2, encoreP1, encoreP2, disabledP1, disabledP2, secP1, secP2, key)
    stateFile = io.open("./battle_ai/state_files/battleStateForShowdown/"..key, "w")
    stateFile:write(
        json.encode({state, "", activeP1, activeP2, encoreP1, encoreP2, disabledP1, disabledP2, secP1, secP2})
    )
    stateFile:close()
    Writer.exec(key)
    emu.frameadvance()
end

function BattleManager:get_action()
    if not using_test_data then print("active", self.game_reader.active) end
    local state = self:getState()
    local thisMove = processor.get_move(frame, state)
    -- print("making move: ", thisMove)
    thisMove.move = thisMove.move + 1
    
    if not using_test_data and thisMove.move > 4 then
        -- 5 means switch to slot 1, 6 means switch to slot 2, etc
        if thisMove.move-4-1 == self.game_reader.active then
            thisMove.move = 5
        end
        for i = 1, 6 do
            if (thisMove.move-5) == self.game_reader.pokemon_order[i] then
                thisMove.move = i+4
                break
            end
        end
    end
    returnAction = thisMove

    self.queued_move = returnAction
end

function BattleManager:get_action_catch()
    if not using_test_data then print("active", self.game_reader.active) end
    local state = self:getState()
    local thisMove = processor.get_move_catch(frame, state)
    -- print("making move: ", thisMove)
    thisMove.move = thisMove.move + 1
    
    if not using_test_data and thisMove.move > 4 and thisMove.move < 11 then
        -- 5 means switch to slot 1, 6 means switch to slot 2, etc
        if thisMove.move-4-1 == self.game_reader.active then
            thisMove.move = 5
        end
        for i = 1, 6 do
            if (thisMove.move-5) == self.game_reader.pokemon_order[i] then
                thisMove.move = i+4
                break
            end
        end
    end
    returnAction = thisMove

    self.queued_move = returnAction
end

function BattleManager:get_switch()
    if self.queued_switch == nil then
        print("registered forced switch")
        local state = self:getState()
        local targetSwitchPokemon = processor.get_switch(frame, state)-4
        local thisMove = nil
        for i = 1, 6 do
            if self.game_reader.pokemon_order[i] == targetSwitchPokemon then
                thisMove = i
                break
            end
        end
        self.queued_switch = thisMove
        print("new queued switch", self.queued_switch)
        return 0
    end
    return self.queued_switch
end

function BattleManager:getState()
    if using_test_data then
        return debug_state
    else
        weather = StateReader.get_weather()
        weatherArray = { 0, 0, 0, 0 }
        if weather == 4 then
            weatherArray[3] = 1
        elseif weather == 3 then
            weatherArray[4] = 1
        elseif weather == 2 then
            weatherArray[2] = 1
        elseif weather == 1 then
            weatherArray[1] = 1
        end

        local returnTable = {}
        
        local index = 1
        returnTable[index] = StateReader.get_remaining_weather_turns()
        index = index + 1

        for i = 0, 3 do
            returnTable[index+i] = weatherArray[i+1]
        end
        index = index + 4

        for i = 0, 8 do
            returnTable[index+i] = self.game_reader.player.hazards[i+1]
        end
        index = index + 9

        for i = 0, 8 do
            returnTable[index+i] = self.game_reader.enemy.hazards[i+1]
        end
        index = index + 9

        for i = 0, 13 do
            returnTable[index+i] = self.game_reader.player.volatiles[i+1]
        end
        index = index + 14

        for i = 0, 13 do
            returnTable[index+i] = self.game_reader.enemy.volatiles[i+1]
        end
        index = index + 14

        local player_pokemon_count = #self.IGReader:get(1)

        local enemy_pokemon_count
        -- if self.game_reader.wild_battle then
            enemy_pokemon_count = #self.IGReader:get(2)
        -- else
        --     enemy_pokemon_count = #self.IGReader:get(5)
        -- end

        -- print(self.IGReader:get(1))
        -- print("")
        -- print(self.IGReader:get(2))
        -- print("pokemon counts", player_pokemon_count, enemy_pokemon_count)

        local boosts_player = StateReader.get_player_boosts(player_pokemon_count)[self.game_reader.active+1]
        for i = 0, 6 do
            returnTable[index+i] = boosts_player[i+1]
        end
        index = index + 7

        local boosts_enemy = StateReader.get_enemy_boosts(player_pokemon_count, enemy_pokemon_count)[self.game_reader.enemy_active+1]
        for i = 0, 6 do
            returnTable[index+i] = boosts_enemy[i+1]
        end
        index = index + 7

        local pokemon_player = StateReader.get_player_pokemon_array(self.game_reader.pokemon_order, player_pokemon_count)
        for i = 0, 179 do
            returnTable[index+i] = pokemon_player[i+1]
        end
        index = index + 180

        local pokemon_enemy = StateReader.get_enemy_pokemon_array(self.game_reader.enemy_active, player_pokemon_count, enemy_pokemon_count)
        for i = 0, 179 do
            returnTable[index+i] = pokemon_enemy[i+1]
        end
        index = index + 180

        if debug_data then 
            local this_state = io.open("./battle_ai/state_files/last_state.json", "w")
            local raw_state = {
                returnTable,
                "N/A_s",
                self.game_reader.active,
                self.game_reader.enemy_active,
                self.game_reader.player.encored_move,
                self.game_reader.enemy.encored_move,
                self.game_reader.player.disabled_move,
                self.game_reader.enemy.disabled_move,
                0, 0
            }
            local state_str = json.encode(raw_state)

            print(raw_state)
            this_state:write(state_str)
            this_state:close()

        end

        return {
            returnTable,
            "N/A_s",
            self.game_reader.active,
            self.game_reader.enemy_active,
            self.game_reader.player.encored_move,
            self.game_reader.enemy.encored_move,
            self.game_reader.player.disabled_move,
            self.game_reader.enemy.disabled_move,
            0, 0
        }
    end
end

function BattleManager.type_id(id)
    if ("Bug" == id) then
        return 1
    elseif ("Dark" == id) then
        return 2
    elseif ("Dragon" == id) then
        return 3
    elseif ("Electric" == id) then
        return 4
    elseif ("Fighting" == id) then
        return 5
    elseif ("Fire" == id) then
        return 6
    elseif ("Flying" == id) then
        return 7
    elseif ("Ghost" == id) then
        return 8
    elseif ("Grass" == id) then
        return 9
    elseif ("Ground" == id) then
        return 10
    elseif ("Ice" == id) then
        return 11
    elseif ("Normal" == id) then
        return 12
    elseif ("Poison" == id) then
        return 13
    elseif ("Psychic" == id) then
        return 14
    elseif ("Rock" == id) then
        return 15
    elseif ("Steel" == id) then
        return 16
    elseif ("Water" == id) then
        return 17
    end
end

if using_test_data then
    my_battle_manager = BattleManager.new()
    -- my_battle_manager:act_open()
    my_battle_manager:act_open_catch()
    my_battle_manager:act_close()
end

return BattleManager
