local md = require "./emu_interface/local_map" -- map data
local goals = require "./emu_interface/goals"
dofile("./emu_interface/table_helper.lua")
local mem = require "./emu_interface/memory_retrieval"
local output_manager = require "./emu_interface/output_manager"
local BattleManager = require "./battle_ai/battle_manager"
local json = require "lunajson"

gamedata_file = io.open("./battle_ai/pokedex/pokedex.json", "r")
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
    },

    -- one for each player 1 pokemon
    moves_used = {
        {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, 
        {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}
    }
}

function exit()
    -- saves global map data
    table.save({ global_map_data = md.get_global_map_data(), current_goal = goals.current_goal, mode = mode, battle_weights = battle_weights }, "./emu_interface/map_cache/global_cache.lua")

    -- saves local map data
    md.pf.save_map(md.map_id)
end

-- runs exit function on close
emu.registerexit(exit)

loaded_saved_data = table.load("./emu_interface/map_cache/global_cache.lua")
if loaded_saved_data ~= nil then
    goals.current_goal = loaded_saved_data.current_goal

    md.set_global_map_data(loaded_saved_data.global_map_data)
    mode = loaded_saved_data.mode
    battle_weights = loaded_saved_data.battle_weights
    loaded_saved_data = nil
end

local last_battle_action = nil
local enemy_pokemon1_types
local catch_threshold = 0.01
local enemy_pokemon1_types = {}

local heal_threshold = 0.01

local replacing_move = false

local is_in_battle = false

while true do
    if not is_in_battle then md.update_map(true) end
    local is_text_onscreen = mem.is_dialogue_onscreen()

    is_in_battle = mem.is_in_battle()
    local can_move = mem.can_move() -- this refers to battle, not actual player movement
    
        
    r1, g1, b1 = gui.getpixel(235, 172)

    if mem.asking_nickname() then
        output_manager.pressB()
        battle_weights.type_info = {
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0
        }
        
    -- okay so this section is to make sure that the
    -- battle doesn't quit out if "is_in_battle" returns
    -- false for a single frame    
    elseif was_in_battle and not is_in_battle and not replacing_move then
        battle_clock = battle_clock + 1
        if battle_clock > 240 then
            md.clear_neighbors()

            enemy_pokemon1_types = {}
            was_in_battle = false
            battleState = nil
            md.gpf.current_path = nil
            mode = 0
        end
    elseif is_in_battle or replacing_move then
        if not was_in_battle then
            battleState = BattleManager.new()
            battle_clock = 0
            was_in_battle = true
        end

        -- that last condition is only met in the battle where the professor
        -- shows the player how to catch pokemon
        if battleState.game_reader.wild_battle and #enemy_pokemon1_types == 0 then

            -- this check has to happen or else the professor showing the player how
            -- to catch pokemon would crash the game
            if #battleState.IGReader:get(5) > 0 then      
                local enemy_pokemon1_types_raw = gamedata[battleState.IGReader:get(5)[1].name].types
                if #enemy_pokemon1_types_raw == 1 then
                    enemy_pokemon1_types_raw[2] = enemy_pokemon1_types_raw[1]
                end
    
                enemy_pokemon1_types = { BattleManager.type_id(enemy_pokemon1_types_raw[1]), BattleManager.type_id(enemy_pokemon1_types_raw[2]) }
            else
                output_manager.pressA()
            end

        end

        local this_line_text = battleState.game_reader:line_text()
        local text_end = this_line_text:sub(-6, -1)
        local learned_new_move = this_line_text:find(" learned ") ~= nil
        replacing_move = this_line_text:find("Should a move ") ~= nil
        local has_caught_this_pokemon = false
        if (battleState.game_reader.wild_battle) then
            local enemy_nickname = battleState.game_reader.nicknames_enemy[1]
            for i = 1, 6 do
                if battleState.game_reader.nicknames[i] == enemy_nickname then
                    has_caught_this_pokemon = true
                    break
                end
            end
        end

        -- this check has to happen or else the professor showing the player how
        -- to catch pokemon would crash the game
        if ((not battleState.game_reader.wild_battle or #battleState.IGReader:get(5) > 0)) then
            if r1 == 8 and g1 == 49 and b1 == 82 or is_forced_switch then -- if forced switch
                local initDelay = 90
                is_forced_switch = true
                local action = battleState:get_switch()
                if action == 0 then
                    output_manager.reset()
                elseif action == 1 then
                    output_manager.press(
                        {
                            {{}, initDelay},
                            {{A = true}, 5},
                            {{A = true}, 5}
                        }, 25
                    )
                elseif action == 2 then
                    output_manager.press({{{}, initDelay}, {{
                        right = true
                    }, 5}, {{
                        A = true
                    }, 20}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 3 then
                    output_manager.press({{{}, initDelay}, {{
                        down = true
                    }, 5}, {{
                        A = true
                    }, 20}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 4 then
                    output_manager.press({{{}, initDelay}, {{
                        down = true
                    }, 5}, {{
                        right = true
                    }, 5}, {{
                        A = true
                    }, 20}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 5 then
                    output_manager.press({{{}, initDelay}, {{
                        down = true
                    }, 5}, {{
                        down = true
                    }, 5}, {{
                        A = true
                    }, 20}, {{
                        A = true
                    }, 5}}, 25)
                elseif action == 6 then
                    output_manager.press({{{}, initDelay}, {{
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
                -- print("exp gain or something")
                output_manager.pressA()
            elseif replacing_move then
                local initDelay = 480
                
                local active = battleState.game_reader.active

                local move_replacing = 0
                local move_replacing_count = 10E10
                for i = 1, 4 do
                    if battle_weights.moves_used[active+1][i] < move_replacing_count then
                        move_replacing = i
                        move_replacing_count = battle_weights.moves_used[active+1][i]
                    end
                end

                local done_with_output = false

                if move_replacing == 1 then
                    done_with_output = output_manager.press({
                        {{}, initDelay},
                        {{A = true}, 1}, 
                        {{up = true}, 5}, 
                        {{left = true}, 5},
                        {{A = true}, 5},
                        {{A = true}, 5}
                    }, 25)
                elseif move_replacing == 2 then
                    done_with_output = output_manager.press(
                    {
                        {{}, initDelay},
                        {{A = true}, 1}, 
                        {{up = true}, 5},
                        {{left = true}, 5}, 
                        {{right = true}, 5}, 
                        {{A = true}, 5},
                        {{A = true}, 5}
                    }, 25)
                elseif move_replacing == 3 then
                    done_with_output = output_manager.press({
                        {{}, initDelay}, {{
                        A = true
                    }, 5}, {{
                        up = true
                    }, 5}, {{
                        left = true
                    }, 5}, {{
                        down = true
                    }, 5}, {{
                        A = true
                    }, 5}, {{
                        A = true
                    }, 5}}, 25)
                elseif move_replacing == 4 then
                    done_with_output = output_manager.press({
                        {{}, initDelay},
                        {{A = true}, 1}, {{
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
                    }, 5}, {{
                        A = true
                    }, 5}}, 25)
                end
                if done_with_output then
                    battle_weights.moves_used[active+1] = {0, 0, 0, 0}
                    replacing_move = false
                end

            elseif learned_new_move then
                local active = battleState.game_reader.active
                battle_weights.moves_used[active+1] = {0, 0, 0, 0}
                output_manager.pressA()
                -- print("learned new move")
            elseif can_move and #battleState.IGReader:get(1) < 6
                and battleState.game_reader.wild_battle 
                and not has_caught_this_pokemon
                and (battle_weights.type_info[ enemy_pokemon1_types[1]] > catch_threshold or battle_weights.type_info[ enemy_pokemon1_types[2] ] > catch_threshold) 
                and mem.has_ball()
            then
                battle_weights.condition = heal_threshold + 1

                local initDelay = 10
                local action_info = battleState:act_catch()
                local action

                if action_info ~= nil then
                    action = action_info.move
                end 

                if action == 0 then
                    -- print("reset output manager")
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
                        {{A = true}, 1},
                    }, 120)
                end
                
            elseif can_move then
                local initDelay = 10
                local action_info = battleState:act()
                local action
                
                local active = battleState.game_reader.active
                
                if action_info ~= nil then 
                    action = action_info.move
                    if action ~= 0 and last_battle_action ~= action then
                        
                        if (action_info.condition) then
                            -- condition manages HP and status conditions
                            -- print("condition pre", battle_weights.condition)
                            -- print("action_info", action_info)
                            battle_weights.condition = (battle_weights.condition + action_info.condition) / 2
                            -- print("condition", battle_weights.condition)
                        end
                        
                        if (action_info.type_info) then
                            -- this manages which types the player wants to catch
                            for i = 1, 17 do
                                battle_weights.type_info[i] = (battle_weights.type_info[i] + action_info.type_info[i]) / 2
                                -- print(i, battle_weights.type_info[i])
                            end
                        end

                        -- this manages which moves the player would delete next
                        -- should they learn a new move
                        if (action > 0 and action < 5) then
                            -- print("active", "action", active, action)
                            battle_weights.moves_used[active+1][action] = 1 + battle_weights.moves_used[active+1][action]
                        end
                        -- print("battle_weights.moves_used", battle_weights.moves_used)


                    end
                end

                if(action == nil) then
                    if output_manager.current_sequence_index > 1 then
                        output_manager.reset()
                    end
                    output_manager.press({
                        {{A = true}, 1},
                    }, 120)
                end
                last_battle_action = action

                if action == 0 then
                    -- print("reset output manager")
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
        output_manager.pressA()
    elseif (mode == 0) then
        -- print("battle_weights.condition: ", battle_weights.condition)
        if (battle_weights.condition > heal_threshold) then
            -- print("mode set to find healing center")
            mode = 2
        else
            mode = 1
        end
    elseif (mode == 2 and goals.attempt_goal()[1] ~= 3) then
        if md.gpf.current_path == nil then

            local healing_destination = {}
            if goals.current_goal < 17 then
                -- mom's house
                healing_destination = {390, 6, 6}
            elseif goals.current_goal < 24 then
                healing_destination = {398, 7, 12}
            else
                healing_destination = {8, 7, 12}
            end
            
            local healing_destination_maps = {
                -- mom's house, accumula pokemon center, stration pokemon center
                   390,         398,                     8
            }

            local healing_destination_x = {
                6, 7, 7
            }

            local healing_destination_y = {
                6, 12, 12
            }

            if not md.gpf.find_global_path(healing_destination_maps, healing_destination_x, healing_destination_y) then
                md.wander()
            else
                output_manager.reset()
            end
        else
            -- check the result of our path manager
            local local_path_response = md.pf.abs_manage_path_to(unpack(md.gpf.current_path[1]))

            if local_path_response == 1 then -- if the destination has been reached    
                md.gpf.current_path = nil
                output_manager.pressA()
                -- print("healed")
                battle_weights.condition = 0
                mode = 0
            end
        end

    elseif (mode == 1 or goals.attempt_goal()[1] == 3) then
        objective = goals.attempt_goal()

        if objective ~= -1 then -- if we aren't out of goals to complete
            if objective[1] == 0 or objective[1] == 1 or objective[1] == 3 or objective[1] == 4 then -- if the goal is to move to coordinates
                local to_map, to_x, to_y
                
                
                if objective[1] ~= 4 then
                    to_map, to_x, to_y = unpack(objective[2]) 
                else
                    to_map = objective[2][1]
                    to_x, to_y = unpack( mem.get_npc_locations()[ objective[2][2] ] )
                    to_x = to_x - 1
                end

                
                if md.gpf.current_path == nil then
                    local find_result = md.gpf.find_global_path(to_map, to_x, to_y)
                    if not find_result then
                        md.wander()
                    else
                        output_manager.reset()
                    end
                else
                    -- check the result of our path manager

                    local local_path_response = md.pf.abs_manage_path_to(unpack(md.gpf.current_path[1]))

                    if local_path_response == 1 then -- if the destination has been reached
                        -- print("local destination reached")
                        -- print(md.gpf.current_path[1])

                        
                        if #md.gpf.current_path > 1 then
                            table.remove(md.gpf.current_path, 1)
                        else
                            if objective[1] == 4 then

                                local output_result = output_manager.press(
                                    {
                                        {{right = true}, 3},
                                        {{A = true}, 1}
                                    }, 0
                                )

                                -- print("output_result", output_result)

                                if output_result then
                                    goals.objective_complete()
                                    md.gpf.current_path = nil
                                end
                            else
                                goals.objective_complete()
                                md.gpf.current_path = nil
                            end

                        end


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
                if (output_manager.press({objective[2]}, 100)) then
                    goals.objective_complete()
                    output_manager.reset()
                end
            end
        end
    end

    emu.frameadvance()
end
