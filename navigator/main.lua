local md = require "local_map" -- map data
local goals = require "goals"

-- the purpose of "mode" is to determine what
-- game actions the bot is attempting to perform
-- 0 => bot needs to decide
-- 1 => goals
local mode = 1

while true do
    md.update_map(true)
    if (mode == 1) then
        objective = goals.attempt_goal()

        if objective ~= -1 then -- if we aren't out of goals to complete
            if objective[1] == 0 or objective[1] == 1 then -- if the goal is to move to coordinates
                to_map, to_x, to_y = unpack(objective[2])

                if md.gpf.current_path == nil then
                    if not md.gpf.find_global_path(to_map, to_x, to_y) then
                        -- print("not enough information to traverse global map: wander")
                        md.wander()
                    else
                        print("enough information to traverse global map")
                    end
                else
                    -- check the result of our path manager
                    local_path_response = md.pf.abs_manage_path_to(unpack(md.gpf.current_path[1]))
                    print(local_path_response)

                    if local_path_response == 1 then -- if the destination has been reached
                        print("local destination reached")
                        table.remove(md.gpf.current_path, 1)
                        goals.objective_complete()

                        if objective[3][1] == 0 then -- if the goal return control to main
                            mode = 0
                        end
                    elseif local_path_response == 2 then -- if the player warped
                        print "warped"

                        if objective[1] == 1 then -- if the objective was to warp

                            -- if the player successfully went to location and warped
                            if to_map == md.pf.last_map and to_x == md.pf.last_x + md.pf.move_x_dir and to_y == md.pf.last_y +
                                md.pf.move_y_dir then
                                goals.objective_complete()
                                md.gpf.current_path = nil
                            end
                        else
                            goals.objective_fail()
                        end
                    end
                end

                
            end
        end
    end

    emu.frameadvance()
end
