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
        {2, {{up = true}, 50}, {1, 1}},
        {2, {{A = true}, 100}, {1, 1}},
        
        {2, {{up = true}, 20}, {1, 1}},
        {2, {{A = true}, 1}, {1, 1}},
        {0, {397, 786, 658}, {1, 1}},
        {0, {319, 786, 613}, {1, 1}},
        {0, {6, 782, 588}, {1, 1}}, -- in Stration City
        
        {0, {6, 780, 588}, {1, 1}},
        {0, {6, 781, 588}, {1, 1}},
        {0, {8, 7, 19}, {1, 1}},
        {0, {6, 774, 587}, {1, 1}}, 
        {0, {15, 8, 2}, {1, 1}},

        {2, {{right = true}, 20}, {1, 1}},
        {2, {{A = true}, 1}, {1, 1}},
        {0, {6, 788, 588}, {1, 1}},
        {2, {{up = true}, 20}, {1, 1}},
        {2, {{A = true}, 1}, {1, 1}},

        {0, {6, 788, 587}, {1, 1}},
        {0, {7, 15, 36}, {1, 1}},
        {0, {7, 9, 26}, {1, 1}},

    }
}

goal_manager.attempt_goal = function()
    if goal_manager.current_goal > #goal_manager.goals then return -1 end
    return goal_manager.goals[goal_manager.current_goal]
end

goal_manager.objective_complete = function()
    print("")
    print("goal complete", goal_manager.current_goal, goal_manager.goals[goal_manager.current_goal])
    print("")
    goal_manager.current_goal = goal_manager.current_goal + goal_manager.goals[goal_manager.current_goal][3][1]
end

goal_manager.objective_fail = function()
    print "goal fail"
    goal_manager.current_goal = goal_manager.current_goal + goal_manager.goals[goal_manager.current_goal][3][2]
end

return goal_manager