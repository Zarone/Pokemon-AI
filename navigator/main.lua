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
        
        if objective[1] == 0 then -- if the goal is to move to coordinates
            if lmd.pf.manage_path_to( unpack(objective[2]) ) then
                goals.objective_complete()
                print("objective complete")
                mode = 0
            end
        end
    end

    emu.frameadvance()
end