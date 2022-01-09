Writer = require "./battle_ai/showdown_writer"
PokeReader = require "./battle_ai/ram_reader/gen5_pokemonreader"
json = require "lunajson"
StateReader = require "./battle_ai/ram_reader/gen5_statereader"
GameReader = require "./battle_ai/ram_reader/gen5_logreader"

BattleManager = {}
BattleManager.__index = BattleManager

function BattleManager.new()
    instance = setmetatable({}, BattleManager)
    
    x = PokeReader.new(4, 5)
    instance.IGReader = x
    team1 = instance.IGReader:get(1)
    team2 = instance.IGReader:get(2)
    str_team1 = Writer.to_packed_team(team1)
    str_team2 = Writer.to_packed_team(team2)
    instance.showdown_instance = Writer.new(str_team1, str_team2)
    -- instance.showdown_instance:write(">p1 switch 2\n")
    -- instance.showdown_instance:write(">p2 switch 3\n")
    instance.showdown_instance:close()
    
    names = {}
    names_enemy = {}
    
    for i, v in pairs(team1) do
        table.insert(names, v.nickname)
    end
    for i, v in pairs(team2) do
        table.insert(names_enemy, v.nickname)
    end
    
    instance.game_reader = GameReader.new(StateReader.is_wild_battle(), names, names_enemy)
    return instance
end


    

-- file = io.open("./state_files/battleState.json", "w")
-- file:write(
--     json.encode({
--         weather = StateReader.get_weather(),
--         turns_left_of_weather = StateReader.get_remaining_weather_turns(),
--         player = {
--             boosts = {StateReader.get_player_boosts()},
--             statuses = {StateReader.get_player_status()},
--             hazards = game_reader.player.hazards,
--             volatiles = game_reader.player.volatiles,
--             active = game_reader.active
--         },
--         enemy = {
--             boosts = {StateReader.get_enemy_boosts()},
--             statuses = {StateReader.get_enemy_status()},
--             hazards = game_reader.enemy.hazards,
--             volatiles = game_reader.enemy.volatiles,
--             active = game_reader.enemy_active
--         }
--     })
-- )

function BattleManager:between_turns()
    self.game_reader:get_line()
end

function BattleManager:get_action()
    return 0 -- indicates moveslot 1
end

return BattleManager