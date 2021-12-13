
battle_ai = {}

battle_ai.find_win_chance = function(battle_status)
    -- return the result from the actual ai
end

battle_ai.find_best_option = function(layer)
    -- create node tree-like structure represented by an array.
    -- make easy navigation methods for this structure.

    -- make a node tree representing the given possibilities.
    -- each actual value of this tree contains the result from "find_win_chance" as well 
    -- as the player option (and maybe opponent option if needed) that brought it to that point.
end

return battle_ai