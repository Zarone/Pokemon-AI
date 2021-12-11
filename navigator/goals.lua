goal_manager = {
    current_goal = 1,

    -- array of goals
    -- first value corresponds to type of action
    -- 0: go to coords {x, y}
    -- second value is data for the first value
    -- third value states how the current_goal should change upon {completion, failure}
    goals = {
        {0, {1, 3}, {0, 0}}
    }
}

goal_manager.attempt_goal = function()
    return goal_manager.goals[goal_manager.current_goal]
end

goal_manager.objective_complete = function()
    goal_manager.current_goal = goal_manager.current_goal + goal_manager.goals[goal_manager.current_goal][3][1]
end

return goal_manager