local md = require "./navigator/local_map" -- map data
local goals = require "./navigator/goals"
dofile("./navigator/table_helper.lua")
local mem = require "./navigator/memory_retrieval"
-- local button_masher = require "button_masher"
local output_manager = require "./navigator/output_manager"
local BattleManager = require "./battle_ai/battle_manager"
local json = require "lunajson"

gamedata_file = io.open("./battle_ai/gamedata/pokedex.json", "r")
local gamedata = json.decode(gamedata_file:read())
gamedata_file:close()


-- the purpose of "mode" is to determine what
-- game actions the bot is attempting to perform
-- 0 => bot needs to decide
-- 1 => goals
-- 2 => healing
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



-- so when the player is in battle, there's a chance the "is_in_battle"
-- function returns false for a frame or two. This variable makes sure the battle 
-- doesn't accidentally end prematurally
local battle_clock = 0
local battle_weights = {
    condition = 0,
    type_info = {
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0
    }
}
local last_battle_action = nil
local enemy_pokemon1_types
local catch_threshold = -0.01
local enemy_pokemon1_types = {}

while true do
    if not is_in_battle then md.update_map(true) end
    controls = joypad.get(1)
    is_text_onscreen = mem.is_dialogue_onscreen()
    is_in_battle = mem.is_in_battle()
    can_move = mem.can_move()
    
        
    r1, g1, b1 = gui.getpixel(235, 172)

    -- okay so this section is to make sure that the
    -- battle doesn't quit out if "is_in_battle" returns
    -- false for a single frame
    
    if mem.asking_nickname() then
        output_manager.pressB()
    elseif was_in_battle and not is_in_battle then
        battle_clock = battle_clock + 1
        if battle_clock > 240 then
            print("battle ended")
            enemy_pokemon1_types = {}
            was_in_battle = false
            battleState = nil
            mode = 0
            -- md.pf.clear_neighbors()
        end
    elseif is_in_battle then
        if not was_in_battle then
            battleState = BattleManager.new()
            battle_clock = 0
            was_in_battle = true
            print("battle started")
        end

        -- that last condition is only met in the battle where the professor
        -- shows the player how to catch pokemon
        if battleState.game_reader.wild_battle and #enemy_pokemon1_types == 0 then

            -- this check has to happen or else the professor showing the player how
            -- to catch pokemon would crash the game
            if #battleState.IGReader:get(5) > 0 then      
                print("changed to wild battle")
                local enemy_pokemon1_types_raw = gamedata[battleState.IGReader:get(5)[1].name].types
                if #enemy_pokemon1_types_raw == 1 then
                    enemy_pokemon1_types_raw[2] = enemy_pokemon1_types_raw[1]
                end
    
                enemy_pokemon1_types = { BattleManager.type_id(enemy_pokemon1_types_raw[1]), BattleManager.type_id(enemy_pokemon1_types_raw[2]) }
                print(enemy_pokemon1_types)
                print(battle_weights.type_info[ enemy_pokemon1_types[1]], battle_weights.type_info[ enemy_pokemon1_types[2] ])
            else
                output_manager.pressA()
            end

        end

        -- print("catch decision", battle_weights.type_info[ enemy_pokemon1_types[1]], battle_weights.type_info[ enemy_pokemon1_types[2] ], catch_threshold)

        text_end = battleState.game_reader:line_text():sub(-6, -1)

        -- print("catch conditions: ", #battleState.IGReader:get(1) < 6, battleState.game_reader.wild_battle, enemy_pokemon1_types[1] and enemy_pokemon1_types[2] and (battle_weights.type_info[ enemy_pokemon1_types[1]] > catch_threshold or battle_weights.type_info[ enemy_pokemon1_types[2] ] > catch_threshold), mem.has_ball())

        -- this check has to happen or else the professor showing the player how
        -- to catch pokemon would crash the game
        if ((not battleState.game_reader.wild_battle or #battleState.IGReader:get(5) > 0)) then
            if battleState.game_reader.wild_battle and memory.readbyte(0x022DF58E) == 33 then -- if it's asking "switch or run"
                -- print("if it's asking switch or run")
                print("switch or run")
                output_manager.pressA()
                -- action = battleState:get_switch()
            elseif r1 == 8 and g1 == 49 and b1 == 82 or is_forced_switch then -- if forced switch
                print('forced switch')
                is_forced_switch = true
                action = battleState:get_switch()
                if action == 0 then
                    print("reset output manager")
                    output_manager.reset()
                elseif action == 1 then
                    output_manager.press({{{}, 5}, {{
                        A = true
                    }, 5}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 2 then
                    output_manager.press({{{}, 5}, {{
                        right = true
                    }, 5}, {{
                        A = true
                    }, 20}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 3 then
                    output_manager.press({{{}, 5}, {{
                        down = true
                    }, 5}, {{
                        A = true
                    }, 20}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 4 then
                    output_manager.press({{{}, 5}, {{
                        down = true
                    }, 5}, {{
                        right = true
                    }, 5}, {{
                        A = true
                    }, 20}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 5 then
                    output_manager.press({{{}, 5}, {{
                        down = true
                    }, 5}, {{
                        down = true
                    }, 5}, {{
                        A = true
                    }, 20}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 6 then
                    output_manager.press({{{}, 5}, {{
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

                if (output_manager.current_sequence_index == 1 and output_manager.between_actions) then
                    is_forced_switch = false
                end
            elseif text_end == "oints!" or text_end == "nning!" then -- if battle is over and money or exp gains are happening
                print("exp gain or something")
                output_manager.pressA()
            elseif can_move and #battleState.IGReader:get(1) < 6 and battleState.game_reader.wild_battle and (battle_weights.type_info[ enemy_pokemon1_types[1]] > catch_threshold or battle_weights.type_info[ enemy_pokemon1_types[2] ] > catch_threshold) and mem.has_ball() then
                -- print("want to catch this \'mon")
                -- print("type 1 weight: ", battle_weights.type_info[ enemy_pokemon1_types[1]])
                -- print("type 2 weight: ", battle_weights.type_info[ enemy_pokemon1_types[2]])

                -- print(battleState.game_reader.last_str)

                local initDelay = 10
                local action_info = battleState:act_catch()
                -- print("action_info", action_info)
                local action
                if action_info ~= nil then
                    action = action_info.move
                end 
                -- print("action", action)

                if action == 0 then
                    print("reset output manager")
                    output_manager.reset()
                elseif action == 1 then
                    output_manager.press({
                        {{}, initDelay},
                        {{up = true}, 5}, 
                        {{A = true}, 5}, 
                        {{up = true}, 5}, 
                        {{left = true}, 5},
                        {{A = true}, 5}
                    }, 25)
                elseif action == 2 then
                    output_manager.press(
                    {
                        {{}, initDelay},
                        {{up = true}, 5},
                        {{A = true}, 5},
                        {{up = true}, 5},
                        {{
                        left = true
                    }, 5}, {{
                        right = true
                    }, 5}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 3 then
                    output_manager.press({
                        {{}, initDelay},
                        {{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({
                        {{}, initDelay},
                        {{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({
                        {{}, initDelay},
                        {{ up = true }, 5}, 
                    {{ down = true }, 5}, {{
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
                    output_manager.press({
                        {{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({{{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({{{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({{{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({{{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
                elseif action == 11 then
                    -- Throw the first pokeball queued from the bag

                    -- If I really wanted to I could add a more verbose system
                    -- to select the optimal ball, but I just don't think I need
                    -- to.
                    output_manager.press({
                        {{}, initDelay},
                        {{left = true}, 5}, 
                        {{down = true}, 5}, 
                        {{A = true}, 5}, 
                        {{}, 5},
                        {{right = true}, 5}, 
                        {{A = true}, 5},
                        {{A = true}, 5},
                        {{down = true}, 5},
                        {{A = true}, 5},
                        {{A = true}, 5},
                    }, 25)
                else
                    if output_manager.current_sequence_index > 1 then
                        output_manager.reset()
                    end
                    output_manager.press({
                        {{A = true}, 5},
                    }, 5)
                end
                
            elseif can_move then
                local initDelay = 10
                local action_info = battleState:act()
                local action
                
                -- print("action_info", action_info)

                if action_info ~= nil then 
                    action = action_info.move
                    if action ~= 0 and last_battle_action ~= action then
                        battle_weights.condition = (battle_weights.condition + action_info.condition) / 2
                        print("condition", battle_weights.condition)
                        for i = 1, 17 do
                            battle_weights.type_info[i] = (battle_weights.type_info[i] + action_info.type_info[i]) / 2
                            print(i, battle_weights.type_info[i])
                        end
                    end
                end


                if(action == nil) then
                    output_manager.current_sequence_index = 1
                    output_manager.press({
                        {{A = true}, 5}
                    }, 25)
                end
                last_battle_action = action

                if action == 0 then
                    print("reset output manager")
                    output_manager.reset()
                elseif action == 1 then
                    output_manager.press({
                        {{}, initDelay},
                        {{up = true}, 5}, 
                        {{A = true}, 5}, 
                        {{up = true}, 5}, 
                        {{left = true}, 5},
                        {{A = true}, 5}
                    }, 25)
                elseif action == 2 then
                    output_manager.press(
                    {
                        {{}, initDelay},
                        {{up = true}, 5},
                        {{A = true}, 5},
                        {{up = true}, 5},
                        {{
                        left = true
                    }, 5}, {{
                        right = true
                    }, 5}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 3 then
                    output_manager.press({
                        {{}, initDelay},
                        {{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({
                        {{}, initDelay},
                        {{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({
                        {{}, initDelay},
                        {{ up = true }, 5}, 
                    {{ down = true }, 5}, {{
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
                    output_manager.press({
                        {{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({{{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({{{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({{{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
                    output_manager.press({{{}, initDelay},{{
                        up = true
                    }, 5}, {{
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
            else
                battleState.game_reader:get_line()
            end
        end

        -- button_masher.mash({A = true})
        -- output_manager.press( {{{A = true}, 5}}, 5 )
    elseif ((not was_in_battle) and is_text_onscreen) then
        -- print("there's on screen dialogue, time to button mash")
        -- button_masher.mash({A = true})
        output_manager.pressA()
    elseif (mode == 0) then
        print("battle_weights.condition: ", battle_weights.condition)
        if (goals.current_goal > 3 and battle_weights.condition > 0.3) then
            mode = 2
        else
            mode = 1
        end
    elseif (mode == 2) then
        if goals.current_goal < 10 then                
            if md.gpf.current_path == nil then
                -- this is the location of the player's mother
                if not md.gpf.find_global_path(390, 6, 6) then
                    md.wander()
                else
                    output_manager.reset()
                end
            else
                -- check the result of our path manager
                local_path_response = md.pf.abs_manage_path_to(unpack(md.gpf.current_path[1]))
    
                if local_path_response == 1 then -- if the destination has been reached
                    print("local destination reached")
    
                    -- maybe check this spot if there's a bug in the future, I don't know why this was here
                    -- table.remove(md.gpf.current_path, 1)
                    md.gpf.current_path = nil
                    output_manager.pressA()
                    mode = 0
                end
            end
        else
            print("find nearing pokemon center")
        end
    elseif (mode == 1) then
        -- print("main: can_move: ", can_move)
        objective = goals.attempt_goal()
        -- print(objective)

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
                        output_manager.reset()
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
                -- print({objective[2][1]}, 100)
                if (output_manager.press({objective[2]}, 100)) then
                    goals.objective_complete()
                    output_manager.reset()
                end
            end
        end
    end

    emu.frameadvance()
end
