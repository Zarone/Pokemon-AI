local md = require "./navigator/local_map" -- map data
local goals = require "./navigator/goals"
dofile("./navigator/table_helper.lua")
local mem = require "./navigator/memory_retrieval"
-- local button_masher = require "button_masher"
local output_manager = require "./navigator/output_manager"
local BattleManager = require "./battle_ai/battle_manager"

-- the purpose of "mode" is to determine what
-- game actions the bot is attempting to perform
-- 0 => bot needs to decide
-- 1 => goals
local mode = 1

local battleState = nil
local was_in_battle = false

-- function exit()
--     print("saving data")
--     -- saves global map data
--     table.save({ global_map_data = md.get_global_map_data(), current_goal = goals.current_goal }, "./map_cache/global_map_cache.lua")
-- end

-- -- runs exit function on close
-- emu.registerexit(exit)

-- loaded_saved_data = table.load("./map_cache/global_map_cache.lua")
-- if loaded_saved_data ~= nil then
--     goals.current_goal = loaded_saved_data.current_goal
--     print("current_goal: ", goals.current_goal)    

--     md.set_global_map_data(loaded_saved_data.global_map_data)
--     loaded_saved_data = nil
-- end

while true do
    md.update_map(true)
    controls = joypad.get(1)
    is_text_onscreen = mem.is_dialogue_onscreen()
    is_in_battle = mem.is_in_battle()
    can_move = mem.can_move()

    -- print(is_text_onscreen)

    if was_in_battle and not is_in_battle then
        print("battle ended")
        was_in_battle = false
        battleState = nil
    end

    if is_in_battle then
        -- print("is in battle")
        if not was_in_battle then
            print("battle started")
            was_in_battle = true
            battleState = BattleManager.new()
        end
        action = battleState:act()
        -- print "should i pres  things"
        if action == 0 then
            output_manager.reset()
        elseif action == 1 then
            -- print("press things")
            output_manager.press({{{}, 5}, {{
                A = true
            }, 5}, {{
                up = true
            }, 5}, {{
                left = true
            }, 5}, {{
                A = true
            }, 5}}, 25)
        elseif action == 2 then
            -- print("press things")
            output_manager.press({{{}, 5}, {{
                A = true
            }, 5}, {{
                up = true
            }, 5}, {{
                left = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 5}}, 25)
        elseif action == 3 then
            -- print("press things")
            output_manager.press({{{}, 5}, {{
                A = true
            }, 5}, {{
                up = true
            }, 5}, {{
                left = true
            }, 5}, {{
                down = true
            }, 5}, {{
                A = true
            }, 5}}, 25)
        elseif action == 4 then
            -- print("press things")
            output_manager.press({{{}, 5}, {{
                A = true
            }, 5}, {{
                up = true
            }, 5}, {{
                left = true
            }, 5}, {{
                down = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 5}}, 25)
        elseif action == 5 then
            output_manager.press({{{}, 5}, {{
                down = true
            }, 5}, {{
                right = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 60}, {{
                A = true
            }, 20}, {{
                A = true
            }, 5}}, 25)
        elseif action == 6 then
            output_manager.press({{{}, 5}, {{
                down = true
            }, 5}, {{
                right = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 60}, {{
                right = true
            }, 5}, {{
                A = true
            }, 20}, {{
                A = true
            }, 5}}, 25)
        elseif action == 7 then
            output_manager.press({{{}, 5}, {{
                down = true
            }, 5}, {{
                right = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 60}, {{
                down = true
            }, 5}, {{
                A = true
            }, 20}, {{
                A = true
            }, 5}}, 25)
        elseif action == 8 then
            output_manager.press({{{}, 5}, {{
                down = true
            }, 5}, {{
                right = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 60}, {{
                down = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 20}, {{
                A = true
            }, 5}}, 25)
        elseif action == 9 then
            output_manager.press({{{}, 5}, {{
                down = true
            }, 5}, {{
                right = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 60}, {{
                down = true
            }, 5}, {{
                down = true
            }, 5}, {{
                A = true
            }, 20}, {{
                A = true
            }, 5}}, 25)
        elseif action == 10 then
            output_manager.press({{{}, 5}, {{
                down = true
            }, 5}, {{
                right = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 60}, {{
                down = true
            }, 5}, {{
                down = true
            }, 5}, {{
                right = true
            }, 5}, {{
                A = true
            }, 20}, {{
                A = true
            }, 5}}, 25)
        end
        -- button_masher.mash({A = true})
        -- output_manager.press( {{{A = true}, 5}}, 5 )
    elseif (is_text_onscreen) then
        print("there's on screen dialogue, time to button mash")
        -- button_masher.mash({A = true})
        output_manager.press({{{
            A = true
        }, 5}}, 5)
    elseif (mode == 1) then
        -- print("main: can_move: ", can_move)
        objective = goals.attempt_goal()

        if objective ~= -1 then -- if we aren't out of goals to complete
            if objective[1] == 0 or objective[1] == 1 then -- if the goal is to move to coordinates
                to_map, to_x, to_y = unpack(objective[2])

                if md.gpf.current_path == nil then
                    if not md.gpf.find_global_path(to_map, to_x, to_y) then
                        -- print("not enough information to traverse global map: wander")
                        md.wander()
                        -- print(md.local_map)
                    else
                        -- print("enough information to traverse global map")
                    end
                else
                    -- check the result of our path manager
                    local_path_response = md.pf.abs_manage_path_to(unpack(md.gpf.current_path[1]))
                    -- print("main: decided on path: ", md.gpf.current_path[1])
                    -- print("main: result of path: ", local_path_response)

                    if local_path_response == 1 then -- if the destination has been reached
                        print("local destination reached")

                        -- maybe check this spot if there's a bug in the future, I don't know why this was here
                        -- table.remove(md.gpf.current_path, 1)

                        md.gpf.current_path = nil

                        goals.objective_complete()

                        if objective[3][1] == 0 then -- if the goal return control to main
                            mode = 0
                        end
                    elseif local_path_response == 2 then -- if the player warped
                        print "warped"

                        if objective[1] == 1 then -- if the objective was to warp

                            -- if the player successfully went to location and warped
                            if to_map == md.pf.last_map and to_x == md.pf.last_x + md.pf.move_x_dir and to_y ==
                                md.pf.last_y + md.pf.move_y_dir then
                                goals.objective_complete()
                                md.gpf.current_path = nil
                            end
                            -- else
                            --     goals.objective_fail()
                        end
                    end
                end

            elseif objective[1] == 2 then
                if (button_masher.mash(objective[2][1], 100)) then
                    goals.objective_complete()
                    button_masher.reset_time()
                end
            end
        end
    end

    emu.frameadvance()
end
