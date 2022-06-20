goal_manager = {
    current_goal = 1,

    -- array of goals
    -- first value corresponds to type of action
    -- 0: go to position {map, x, y}
    -- 1: go to position and warp {map, x, y}
    -- 2: press a button {{button = true}, how_long}
    -- 3: go to position {map, x, y} and it overrides desire to heal
    -- second value is data for the first value
    -- third value states how the current_goal should change upon {completion, failure}
    goals = {
        {0, {391, 5, 7}, {1, 1}},
        {2, {{A = true}, 100}, {1, 1}},
        {0, {392, 6, 10}, {1, 1}}, -- go to Bianca's house
        {0, {389, 782, 748}, {1, 1}}, -- go back home to ensure player knows about warp there
        {0, {389, 777, 742}, {1, 1}}, -- go to professor's house

        {2, {{up = true}, 20}, {1, 1}},
        {2, {{A = true}, 100}, {1, 1}}, -- talk to Cheren
        {0, {389, 787, 739}, {1, 1}}, -- go up to watch professor catch pokemon
        {0, {317, 789, 673}, {1, 1}}, -- (make sure player walks in right direction when wander to Accumula town)
        {0, {317, 788, 672}, {1, 1}}, -- (make sure player walks in right direction when wander to Accumula town)
        
        {0, {317, 789, 672}, {1, 1}}, -- go to Accumula town
        {0, {397, 796, 659}, {1, 1}}, -- go to talk to professor in front of pokemon center
        {2, {{up = true}, 50}, {1, 1}}, -- correct orientation
        {2, {{A = true}, 100}, {1, 1}}, -- start dialogue
        {2, {{up = true}, 20}, {1, 1}}, -- correct orienation in pokemon center
        
        {2, {{A = true}, 1}, {1, 1}}, -- start dialogue in pokemon center
        {0, {397, 797, 658}, {1, 1}}, -- go in front of Accumula town pokemon center
        {0, {397, 795, 658}, {1, 1}},
        {0, {397, 796, 659}, {1, 1}},
        {0, {397, 796, 658}, {1, 1}},

        {0, {398, 7, 19}, {1, 1}}, -- go into Accumula town pokemon center
        {0, {397, 786, 658}, {1, 1}}, -- go to the team plasma monologue
        {0, {319, 753, 647}, {1, 1}},
        {0, {320, 14, 6}, {1, 1}}, -- try to get player to build warp between 320 and 397
        {0, {320, 14, 4}, {1, 1}},
        
        {0, {320, 15, 5}, {1, 1}},
        {0, {397, 769, 649}, {1, 1}},
        {0, {319, 786, 613}, {1, 1}},
        {0, {319, 786, 608}, {1, 1}},
        {2, {{up = true}, 50}, {1, 1}},

        {3, {6, 782, 588}, {1, 1}}, -- in Stration City
        {3, {6, 780, 588}, {1, 1}},
        {3, {6, 781, 589}, {1, 1}},
        {3, {6, 781, 588}, {1, 1}},
        {3, {8, 7, 19}, {1, 1}}, -- Stration city pokemon center

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

        {0, {7, 12, 16}, {1, 1}},
        {0, {7, 12, 4}, {1, 1}},
        {2, {{A = true}, 1}, {1, 1}},
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