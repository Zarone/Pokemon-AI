goal_manager = {
    current_goal = 1,

    -- array of goals
    -- first value corresponds to type of action
    -- 0: go to position {map, x, y}
    -- second value is data for the first value
    -- third value states how the current_goal should change upon {completion, failure}
    goals = {
        {1, {390, 6, 11}, {1, 1}},
        {1, {389, 782, 748}, {1, 1}},
        {1, {390, 6, 11}, {1, 1}},
        {0, {389, 777, 742}, {1, 1}}
    }
}

goal_manager.attempt_goal = function()
    if goal_manager.current_goal > #goal_manager.goals then return -1 end
    return goal_manager.goals[goal_manager.current_goal]
end

goal_manager.objective_complete = function()
    print "goal complete"
    goal_manager.current_goal = goal_manager.current_goal + goal_manager.goals[goal_manager.current_goal][3][1]
end

goal_manager.objective_fail = function()
    print "goal fail"
    goal_manager.current_goal = goal_manager.current_goal + goal_manager.goals[goal_manager.current_goal][3][2]
end

return goal_manager