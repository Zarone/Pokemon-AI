-- require "showdown_writer"
-- require "./ram_reader/gen_5_pokemonreader"
-- IGReader = PokeReader.new(4, 5, 1)
-- team1 = Writer.to_packed_team(IGReader:get(1))
-- team2 = Writer.to_packed_team(IGReader:get(2))
-- showdown_instance = Writer.new(team1, team2)
-- showdown_instance:close()
json = require "lunajson"
require "./ram_reader/gen5_statereader"
require "./process_logs/lua/gen5_direct"

game_reader = GameReader.new()

file = io.open("./state_files/battleState.json", "w")
file:write(json.encode({
    weather = StateReader.get_weather(),
    turns_left_of_weather = StateReader.get_remaining_weather_turns(),
    player = {
        boosts = {StateReader.get_player_boosts()},
        statuses = {StateReader.get_player_status()},
        hazards = game_reader.player.hazards
    },
    enemy = {
        boosts = {StateReader.get_enemy_boosts()},
        statuses = {StateReader.get_enemy_status()},
        hazards = game_reader.enemy.hazards
    }
}))



-- function fn()
--     game_reader:read()
--     print(game_reader.player.hazards, game_reader.enemy.hazards)
-- end

-- gui.register(fn)