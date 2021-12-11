local lmd = require "local_map"
local goals = require "goals" 

-- the purpose of "mode" is to determine what
-- game actions the bot is attempting to perform
-- 0 => bot needs to decide
-- 1 => goals
local mode = 1

while true do
    lmd.update_map(true)
    if (mode == 1) then
        objective = goals.attempt_goal()
        
        if objective ~= -1 then
            print("main: current goal, ", goals.current_goal)
            if objective[1] == 0 then -- if the goal is to move to coordinates
                local_path_response = lmd.pf.manage_path_to( unpack(objective[2]) )
                print("main: local_path_response, ", local_path_response)
                if local_path_response == 1 then
                    goals.objective_complete()
                    print("objective complete")
    
                    if objective[3][1] == 0 then
                        print("returning control to decision maker")
                        mode = 0
                    end
                elseif local_path_response == 2 then -- if the player warped
                    -- print("main: has warped")
                    goals.objective_fail()
                    -- if objective[3][2] == 0 then
                    --     print("returning control to decision maker from fail")
                    --     mode = 0
                    -- end
                    -- mode = 0
                end
            end
        end
    end

    emu.frameadvance()
end