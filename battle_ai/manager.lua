require "showdown_writer"

require "gen_5_pokemonreader"

IGReader = PokeReader.new(4, 5, 1)

team1 = Writer.to_packed_team(IGReader:get(1))
team2 = Writer.to_packed_team(IGReader:get(2))

showdown_instance = Writer.new(team1, team2)

-- showdown_instance = Writer.new()
showdown_instance:close()