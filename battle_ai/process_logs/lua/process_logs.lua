gs = require "game_state"

new_game = gs.GameState.new({ "1", "2" })
print(new_game:get_log()[1])


function get_log(log_name)
    file = io.open(log_name, "r")
    file:lines("a")
end