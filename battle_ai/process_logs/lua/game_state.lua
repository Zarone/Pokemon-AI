local GameState = {}
GameState.__index = GameState

function GameState.new(log_lines)
    instance = setmetatable({}, GameState)
    instance.log = log_lines
    return instance
end

function GameState:get_log()
    return self.log
end

return { GameState = GameState }