using_test_data = false

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

function BattleManager.get_teams(IGReader)

    team1 = IGReader:get(1)

    team2 = nil
    if StateReader.is_wild_battle() then
        team2 = IGReader:get(5)
    else
        team2 = IGReader:get(2)
    end
    
    return team1, team2
end

function BattleManager.get_teams_packed(IGReader)
    team1 = IGReader:get(1)
    str_team1 = Writer.to_packed_team(team1)

    team2 = nil
    if StateReader.is_wild_battle() then
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
        team1, team2 = BattleManager.get_teams(instance_IGReader)
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
        instance_game_reader = GameReader.new(StateReader.is_wild_battle(), names, names_enemy)
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
        else
            team1 = "Mew2|Mewtwo|none|Pressure|psychocut,disable,futuresight,guardswap|Modest|0,0,0,0,0,0||7,16,30,13,12,5||70|72,,]Crustle||none|Sturdy|bugbite,stealthrock,rockslide,slash|Docile|0,0,0,0,0,0||20,0,7,16,26,20||35|72,,]Nidoqueen||none|Poison Point|toxicspikes,superpower,earthpower,furyswipes|Sassy|85,85,85,85,85,85||31,31,31,31,31,31||100|76,,]Qwilfish||Focus Sash|Swift Swim|spikes,pinmissile,takedown,aquatail|Quirky|0,0,0,0,0,0||15,9,22,12,18,14||47|72,,]Hydreigon||Choice Specs|Levitate|dracometeor,fly,darkpulse,focusblast|Timid|6,0,0,252,0,252||31,31,31,31,31,31||100|255,," 
            team2 = "Cofagrigus||none|Mummy|shadowball,psychic,willowisp,energyball|Sassy|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Jellicent||none|Cursed Body|shadowball,psychic,hydropump,sludgewave|Careful|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Froslass||none|Snow Cloak|shadowball,psychic,blizzard,iceshard|Impish|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Drifblim||none|Aftermath|shadowball,psychic,acrobatics,thunder|Quirky|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Golurk||none|Iron Fist|shadowpunch,earthquake,hammerarm,curse|Jolly|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Chandelure||none|Flame Body|shadowball,psychic,fireblast,payback|Calm|0,0,0,0,0,0||30,30,30,30,30,30||73|255,,"
        end
        Writer.saveTeams(team1, team2)
        self:get_action()
        return 0
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
    local state = self:getState()
    local thisMove = processor.get_move(exec_showdown_state, state)
    print("making move: ", thisMove)
    thisMove.move = thisMove.move + 1
    
    if thisMove.move > 4 then
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
    returnAction = thisMove.move

    self.queued_move = returnAction
end

function BattleManager:get_switch()
    if self.queued_switch == nil then
        print("registered forced switch")
        local state = self:getState()
        local targetSwitchPokemon = processor.get_switch(exec_showdown_state, state)-4
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
        return {
            {
                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0,

                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0,

                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,

                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0,

                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0,

                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0,
                
                0, 0, 0, 0, 0,
                100, 92, 105, 90, 125,
                
                90, 98, 0, 0, 0, 
                0, 0, 0, 0, 0,
                
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                
                0, 0, 0, 0, 0,
                100, 70, 105, 125, 65,
                
                75, 45, 0, 0, 0, 
                0, 0, 0, 0, 0, 

                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0,

                0, 0, 0, 0, 0,
                100, 90, 92, 87, 75,

                85, 76, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                1, 65, 95, 85, 55, 
                
                55, 85, 0, 0, 0,
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                100, 106, 110, 90, 154, 
                
                90, 130, 0, 0, 0,
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0,

                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                
                0, 0, 0, 0, 0,
                100, 89, 124, 80, 55,
                
                80, 55, 0, 0, 0,
                0, 0, 0, 0, 0,
                
                0, 0, 0, 0, 0,
                0, 0, 0, 0, 0,
                
                0, 0, 0, 0, 0, 
                100, 58, 50, 145, 95,

                105, 30, 0, 0, 0, 
                0, 0, 0, 0, 0,
                
                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                100, 70, 80, 70, 80, 
                
                70, 110, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                100, 150, 80, 44, 90, 
                
                54, 80, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                0, 100, 60, 70, 85, 
                
                105, 60, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 1,
                100, 60, 55, 90, 145, 
                
                90, 80, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0, 
                0, 0, 0, 0, 0, 
                
                0, 0, 0, 0, 0
            },
            "not switch",
            0,
            3,
            "dracometeor",
            "",
            "darkpulse",
            "",
            0,
            0
        }
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

        local boosts_player = StateReader.get_player_boosts()[self.game_reader.active+1]
        for i = 0, 6 do
            returnTable[index+i] = boosts_player[i+1]
        end
        index = index + 7

        local boosts_enemy = StateReader.get_enemy_boosts()[self.game_reader.enemy_active+1]
        for i = 0, 6 do
            returnTable[index+i] = boosts_enemy[i+1]
        end
        index = index + 7

        local pokemon_player = StateReader.get_player_pokemon_array(self.game_reader.pokemon_order)
        for i = 0, 179 do
            returnTable[index+i] = pokemon_player[i+1]
        end
        index = index + 180

        local pokemon_enemy = StateReader.get_enemy_pokemon_array(self.game_reader.enemy_active)
        for i = 0, 179 do
            returnTable[index+i] = pokemon_enemy[i+1]
        end
        index = index + 180

    
        print("self.game_reader.active in getState", self.game_reader.active)
        return {
            -- {
            --     StateReader.get_remaining_weather_turns(),
            --     unpack(weatherArray),
            --     unpack(self.game_reader.player.hazards),
            --     unpack(self.game_reader.enemy.hazards),
            --     unpack(self.game_reader.player.volatiles),
            --     unpack(self.game_reader.enemy.volatiles),
            --     unpack(StateReader.get_player_boosts()[self.game_reader.active+1]),
            --     unpack(StateReader.get_enemy_boosts()[self.game_reader.enemy_active+1]),
            --     unpack(StateReader.get_player_pokemon_array()),
            --     unpack(StateReader.get_enemy_pokemon_array())
            -- },
            returnTable,
            "N/A_s",
            self.game_reader.active,
            self.game_reader.enemy_active,
            self.game_reader.player.encored_move,
            self.game_reader.enemy.encored_move,
            self.game_reader.player.disabled_move,
            self.game_reader.enemy.disabled_move,
            0, 0
            -- weather = StateReader.get_weather(),
            -- turns_left_of_weather = StateReader.get_remaining_weather_turns(),
            -- player = {
            --     boosts = {StateReader.get_player_boosts()},
            --     statuses = {StateReader.get_player_status()},
            --     hazards = self.game_reader.player.hazards,
            --     volatiles = self.game_reader.player.volatiles,
            --     active = self.game_reader.active,
            --     disable_move = self.game_reader.player.disabled_move,
            --     encored_move = self.game_reader.player.encored_move,
            --     health = StateReader.get_player_health()
            -- },
            -- enemy = {
            --     boosts = {StateReader.get_enemy_boosts()},
            --     statuses = {StateReader.get_enemy_status()},
            --     hazards = self.game_reader.enemy.hazards,
            --     volatiles = self.game_reader.enemy.volatiles,
            --     active = self.game_reader.enemy_active,
            --     disable_move = self.game_reader.enemy.disabled_move,
            --     encored_move = self.game_reader.enemy.encored_move,
            --     health = StateReader.get_enemy_health()
            -- }
        }
    end
end

if using_test_data then
    my_battle_manager = BattleManager.new()
    my_battle_manager:act_open()
    my_battle_manager:act_close()
end

return BattleManager
