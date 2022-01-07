-- require "showdown_writer"
-- require "./ram_reader/gen5_pokemonreader"
-- IGReader = PokeReader.new(4, 5, 1)
-- team1 = IGReader:get(1)
-- team1 = Writer.to_packed_team(IGReader:get(1))
-- team2 = Writer.to_packed_team(IGReader:get(2))
-- showdown_instance = Writer.new(team1, team2)
-- showdown_instance:write(">p1 switch 2\n")
-- showdown_instance:write(">p2 switch 3\n")
-- showdown_instance:close()
-- json = require "lunajson"
require "./ram_reader/gen5_statereader"
-- team2 = IGReader:get(2)
-- for i, v in pairs(team2) do
--     print(v)
-- end
require "./ram_reader/gen5_logreader"

-- print(IGReader:get(1)[1].nickname)
-- print(IGReader:get(1)[2].nickname)
-- print(IGReader:get(1)[3].nickname)
-- print(IGReader:get(1)[4].nickname)
-- print(IGReader:get(1)[5].nickname)
-- print(IGReader:get(1)[6].nickname)

-- names = {}

-- for i, v in pairs(team1) do
--     table.insert(names, v.nickname)
-- end

game_reader = GameReader.new(StateReader.is_wild_battle())

-- file = io.open("./state_files/battleState.json", "w")
-- file:write(json.encode({
--     weather = StateReader.get_weather(),
--     turns_left_of_weather = StateReader.get_remaining_weather_turns(),x
--         boosts = {StateReader.get_player_boosts()},
--         statuses = {StateReader.get_player_status()},
--         hazards = game_reader.player.hazards
--     },
--     enemy = {
--         boosts = {StateReader.get_enemy_boosts()},
--         statuses = {StateReader.get_enemy_status()},
--         hazards = game_reader.enemy.hazards
--     }
-- }))

-- print(game_reader.name)

function fn()
    game_reader:get_line()
end

gui.register(fn)