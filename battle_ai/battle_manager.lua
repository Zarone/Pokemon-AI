Writer = require "showdown_writer"
PokeReader = require "./ram_reader/gen5_pokemonreader"
json = require "lunajson"
StateReader = require "./ram_reader/gen5_statereader"
GameReader = require "./ram_reader/gen5_logreader"

IGReader = PokeReader.new(4, 5, 1)
team1 = Writer.to_packed_team(IGReader:get(1))
team2 = Writer.to_packed_team(IGReader:get(2))
showdown_instance = Writer.new(team1, team2)
showdown_instance:write(">p1 switch 2\n")
showdown_instance:write(">p2 switch 3\n")
showdown_instance:close()
team1 = IGReader:get(1)
team2 = IGReader:get(2)
    
names = {}
names_enemy = {}

for i, v in pairs(team1) do
    table.insert(names, v.nickname)
end
for i, v in pairs(team2) do
    table.insert(names_enemy, v.nickname)
end

game_reader = GameReader.new(StateReader.is_wild_battle(), names, names_enemy)

file = io.open("./state_files/battleState.json", "w")
file:write(
    json.encode({
        weather = StateReader.get_weather(),
        turns_left_of_weather = StateReader.get_remaining_weather_turns(),
        player = {
            boosts = {StateReader.get_player_boosts()},
            statuses = {StateReader.get_player_status()},
            hazards = game_reader.player.hazards,
            volatiles = game_reader.player.volatiles,
            active = game_reader.active
        },
        enemy = {
            boosts = {StateReader.get_enemy_boosts()},
            statuses = {StateReader.get_enemy_status()},
            hazards = game_reader.enemy.hazards,
            volatiles = game_reader.enemy.volatiles,
            active = game_reader.enemy_active
        }
    })
)

function fn()
    game_reader:get_line()
end

gui.register(fn)