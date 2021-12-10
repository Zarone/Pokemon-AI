goal_manager = {
    current_goal = 1,

    -- array of goals
    -- first value corresponds to type of action
    -- 0: go to coords {x, y}
    -- second value is data for the first value
    -- third value states whether or not control should return to decision maker
    goals = {
        {0, {-2, -7}, false},
        {0, {1, 1}, true}
    }
}

goal_manager.attempt_goal = function()
    return goal_manager.goals[goal_manager.current_goal]
end

goal_manager.objective_complete = function()
    goal_manager.current_goal = goal_manager.current_goal + 1
end

return goal_manager