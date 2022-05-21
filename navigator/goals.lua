goal_manager = {
    current_goal = 1,

    -- array of goals
    -- first value corresponds to type of action
    -- 0: go to position {map, x, y}
    -- 1: go to position and warp {map, x, y}
    -- 2: press a button {{button = true}, how_long}
    -- second value is data for the first value
    -- third value states how the current_goal should change upon {completion, failure}
    goals = {
        {0, {391, 5, 7}, {1, 1}},
        {2, {{A = true}, 100}, {1, 1}},
        {0, {392, 6, 10}, {1, 1}},
        {0, {389, 777, 742}, {1, 1}},
        {2, {{A = true}, 100}, {1, 1}},
        {0, {389, 787, 739}, {1, 1}},
        {0, {317, 790, 678}, {1, 1}},
        {0, {397, 796, 659}, {1, 1}},
        {2, {{Up = true}, 100}, {1, 1}},
        {2, {{A = true}, 100}, {1, 1}},

    }
}

goal_manager.attempt_goal = function()
    if goal_manager.current_goal > #goal_manager.goals then return -1 end
    return goal_manager.goals[goal_manager.current_goal]
end

goal_manager.objective_complete = function()
    print("")
    print("goal complete", goal_manager.current_goal)
    print("")
    goal_manager.current_goal = goal_manager.current_goal + goal_manager.goals[goal_manager.current_goal][3][1]
end

goal_manager.objective_fail = function()
    print "goal fail"
    goal_manager.current_goal = goal_manager.current_goal + goal_manager.goals[goal_manager.current_goal][3][2]
end

return goal_manager