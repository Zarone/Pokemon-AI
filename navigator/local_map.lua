local lmd = {} -- local map data

mem = require "./navigator/memory_retrieval"
local gmd = require "./navigator/global_map" -- global map data
dofile("./navigator/table_helper.lua")

lmd.x = nil
lmd.y = nil
-- lmd.z = nil
lmd.map_id = nil

-- 0 is players location -- red
-- 1 is movable space -- white
-- 2 is unmovable space -- black
-- 3 is warp space -- blue
-- 4 is NPC -- green
lmd.local_map = {{nil}}
lmd.map_x_start = 1
lmd.map_x_end = 1
lmd.map_y_start = 1
lmd.map_y_end = 1

-- local_map[y_offset + y+1][x_offset + x+1] = the location of the player on the local map
lmd.x_offset = 0
lmd.y_offset = 0

lmd.debug_box_size = 4
lmd.debug_box_margin = lmd.debug_box_size * 2.5
lmd.horizontal_limit = 10
lmd.vertical_limit = 8

local debug_key = joypad.get().debug

lmd.pf = { -- pathfinder
    path = {},
    ismoving = false,
    move_x_dir = nil,
    move_y_dir = nil,
    frame_counter = 0,
    frame_per_move = 60,
    is_warping = false,
    warp_frame_counter = 0,
    warp_frames_per_warp = 410,
	trying_to_warp_counter = 0,
	trying_to_warp_limit = 180
}

lmd.clear_neighbors = function()
    if (lmd.local_map[lmd.y+lmd.y_offset+2]) then
        if lmd.local_map[lmd.y+lmd.y_offset+2][lmd.x+lmd.x_offset+1] == 2 then
            lmd.local_map[lmd.y+lmd.y_offset+2][lmd.x+lmd.x_offset+1] = nil
        end
    end
    if (lmd.local_map[lmd.y+lmd.y_offset]) then
        if lmd.local_map[lmd.y+lmd.y_offset][lmd.x+lmd.x_offset+1] == 2 then
            lmd.local_map[lmd.y+lmd.y_offset][lmd.x+lmd.x_offset+1] = nil
        end
    end
    if (lmd.local_map[lmd.y+lmd.y_offset+1]) then
        if lmd.local_map[lmd.y+lmd.y_offset+1][lmd.x+lmd.x_offset] == 2 then
            lmd.local_map[lmd.y+lmd.y_offset+1][lmd.x+lmd.x_offset] = nil
        end
        if lmd.local_map[lmd.y+lmd.y_offset+1][lmd.x+lmd.x_offset+2] == 2 then
            lmd.local_map[lmd.y+lmd.y_offset+1][lmd.x+lmd.x_offset+2] = nil
        end
    end
    gmd.fully_explored[lmd.map_id] = false
end

lmd.pf.try_move_start = function(dir_x, dir_y)
    lmd.pf.last_x = lmd.x
    lmd.pf.last_y = lmd.y
    -- print("load map called in try_move_start")
    lmd.pf.load_map()
    lmd.pf.last_map = lmd.map_id
    lmd.pf.ismoving = true
    lmd.pf.move_x_dir = dir_x
    lmd.pf.move_y_dir = dir_y
    -- print("start move to " .. lmd.x_offset + lmd.x + dir_x + 1 .. " " .. lmd.y_offset + dir_y + lmd.y + 1)
end

lmd.pf.try_move = function() -- arguments are either (-1, 0), (0, -1), (0, 1) or (1, 0)
    -- local before = os.clock()
    -- print("elapsed", os.clock()-before)

    local dir = {}

    if (lmd.pf.move_x_dir == 0 and lmd.pf.move_y_dir == -1) then
        dir.up = true
    elseif (lmd.pf.move_x_dir == 0 and lmd.pf.move_y_dir == 1) then
        dir.down = true
    elseif (lmd.pf.move_x_dir == 1 and lmd.pf.move_y_dir == 0) then
        dir.right = true
    elseif (lmd.pf.move_x_dir == -1 and lmd.pf.move_y_dir == 0) then
        dir.left = true
    end

    local same_pos = lmd.pf.last_x == lmd.x and lmd.pf.last_y == lmd.y

    -- repeat the input so the player moves
    if same_pos then
        joypad.set(0, dir)
    end

    -- if lmd.pf.frame_counter % 3 == 0 then print("frame counter", lmd.pf.frame_counter) end

    if lmd.pf.frame_counter > lmd.pf.frame_per_move then
        return lmd.pf.try_move_end(same_pos)
    end

    lmd.pf.frame_counter = lmd.pf.frame_counter + 1
    return 1 -- indicate move needs more time
end

lmd.pf.try_move_end = function(same_pos)
    -- if the character has moved 
    if not same_pos then
        -- if the map hasn't changed
        
        if (lmd.map_id == lmd.pf.last_map and lmd.map_id == mem.get_map()) then

            -- set the last location to movable space
            -- if old_x ~= nil then
            --     lmd.local_map[old_y + lmd.y_offset + 1][old_x + lmd.x_offset + 1] = 1
            -- end

            -- expand the map
            if (lmd.y + lmd.y_offset + 1 < lmd.map_y_start) then
                lmd.map_y_start = lmd.y + lmd.y_offset + 1
            elseif (lmd.y + lmd.y_offset + 1 > lmd.map_y_end) then
                lmd.map_y_end = lmd.y + lmd.y_offset + 1
            end

            if (lmd.x + lmd.x_offset + 1 < lmd.map_x_start) then
                lmd.map_x_start = lmd.x + lmd.x_offset + 1
            elseif (lmd.x + lmd.x_offset + 1 > lmd.map_x_end) then
                lmd.map_x_end = lmd.x + lmd.x_offset + 1
            end
            print("new boundaries", lmd.map_x_start, lmd.map_y_start, lmd.map_x_end, lmd.map_y_end)

            if (lmd.y ~= lmd.pf.last_y) then -- if the y changed
                if (lmd.local_map[lmd.y + lmd.y_offset + 1] == nil) then -- if the new row is nil
                    lmd.local_map[lmd.y + lmd.y_offset + 1] = {}
                end
                if lmd.local_map[lmd.y + lmd.y_offset + 1][lmd.x + lmd.x_offset + 1] ~= 3 then
                    lmd.local_map[lmd.y + lmd.y_offset + 1][lmd.x + lmd.x_offset + 1] = 1
                    -- print("set to movable tile on y: ", lmd.y + lmd.y_offset + 1, lmd.x + lmd.x_offset + 1)
                end
            end

            if (lmd.x ~= lmd.pf.last_x) then -- if the x changed
                if (lmd.local_map[lmd.y + lmd.y_offset + 1] == nil) then
                    print("error in update map, so reloading map")
                    lmd.pf.load_map()
                    return
                end
                if lmd.local_map[lmd.y + lmd.y_offset + 1][lmd.x + lmd.x_offset + 1] ~= 3 then
                    lmd.local_map[lmd.y + lmd.y_offset + 1][lmd.x + lmd.x_offset + 1] = 1
                    -- print("set to movable tile on x: ", lmd.y + lmd.y_offset + 1, lmd.x + lmd.x_offset + 1)
                end
            end

            return 0 -- indicate successfuly move
        else
            print("try_move: has warped")
            lmd.wander_to = nil
            lmd.gpf.current_path = nil

            if lmd.map_id ~= nil then

                -- lmd.map_id = mem.get_map()
                -- set the last location to a warp

                -- expand the map
                print("expand map in try move after warp, from", lmd.pf.last_map, lmd.pf.last_x, lmd.pf.last_y, "to", mem.get_map(), lmd.x, lmd.y)
                print("offsets:", lmd.x_offset, lmd.y_offset)
                print("before", lmd.map_x_start, lmd.map_y_start, lmd.map_x_end, lmd.map_y_end)
                if (lmd.y_offset + lmd.pf.last_y + lmd.pf.move_y_dir + 1 < lmd.map_y_start) then
                    lmd.map_y_start = lmd.y_offset + lmd.pf.last_y + lmd.pf.move_y_dir + 1
                elseif (lmd.y_offset + lmd.pf.last_y + lmd.pf.move_y_dir + 1 > lmd.map_y_end) then
                    lmd.map_y_end = lmd.y_offset + lmd.pf.last_y + lmd.pf.move_y_dir + 1
                end

                if (lmd.x_offset + lmd.pf.last_x + lmd.pf.move_x_dir + 1 < lmd.map_x_start) then
                    lmd.map_x_start = lmd.x_offset + lmd.pf.last_x + lmd.pf.move_x_dir + 1
                elseif (lmd.x_offset + lmd.pf.last_x + lmd.pf.move_x_dir + 1 > lmd.map_x_end) then
                    lmd.map_x_end = lmd.x_offset + lmd.pf.last_x + lmd.pf.move_x_dir + 1
                end
                print("after", lmd.map_x_start, lmd.map_y_start, lmd.map_x_end, lmd.map_y_end)

                -- if the new row is nil
                if lmd.local_map[lmd.y_offset + lmd.pf.last_y + lmd.pf.move_y_dir + 1] == nil then
                    lmd.local_map[lmd.y_offset + lmd.pf.last_y + lmd.pf.move_y_dir + 1] = {}
                end

                print("lmd.local_map["..tostring(lmd.y_offset + lmd.pf.last_y + lmd.pf.move_y_dir + 1).."]["..tostring(lmd.x_offset + lmd.pf.last_x + lmd.pf.move_x_dir + 1).."] = 3")
                lmd.local_map[lmd.y_offset + lmd.pf.last_y + lmd.pf.move_y_dir + 1][lmd.x_offset + lmd.pf.last_x +
                    lmd.pf.move_x_dir + 1] = 3


                if gmd.map[lmd.pf.last_map] == nil then
                    gmd.map[lmd.pf.last_map] = {}
                end

                g_map_has_warp = false
                for i, warp in ipairs(gmd.map[lmd.pf.last_map]) do
                    if 
                        (
                            warp[1] == mem.get_map() and 
                            warp[2] == lmd.pf.last_x + lmd.pf.move_x_dir and 
                            warp[3] == lmd.pf.last_y + lmd.pf.move_y_dir and 
                            warp[4] == lmd.x and warp[5] == lmd.y 
                        )
                    then
                        g_map_has_warp = true
                    end
                end
                if not g_map_has_warp then
                    table.insert(gmd.map[lmd.pf.last_map], {mem.get_map(), lmd.pf.last_x + lmd.pf.move_x_dir,
                    lmd.pf.last_y + lmd.pf.move_y_dir, lmd.x, lmd.y})
                end

                lmd.pf.save_map(lmd.pf.last_map)
                
                lmd.pf.load_map()

            end

            return 4 -- indicate the player warped
        end
    else
        -- moved unsucessfully

        print("failed to move from", lmd.map_id, lmd.pf.last_x, lmd.pf.last_y, "with velocity", lmd.pf.move_y_dir, lmd.pf.move_x_dir)

        local can_player_move = mem.character_can_move()

        -- print(can_player_move)

        if can_player_move and not (lmd.is_npc_at(lmd.x + lmd.x_offset + lmd.pf.move_x_dir + 1,
            lmd.y + lmd.y_offset + lmd.pf.move_y_dir + 1)) then

            -- print("no npc found at: ", lmd.x + lmd.x_offset + 1 + lmd.pf.move_x_dir,
            --     lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir)

            -- expand the map
            print("expand map in try move, from", lmd.pf.last_map, lmd.pf.last_x, lmd.pf.last_y, "to", lmd.map_id, lmd.x, lmd.y)

            if (lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir < lmd.map_y_start) then
                lmd.map_y_start = lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir
            elseif (lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir > lmd.map_y_end) then
                lmd.map_y_end = lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir
            end

            if (lmd.x + lmd.x_offset + 1 + lmd.pf.move_x_dir < lmd.map_x_start) then
                lmd.map_x_start = lmd.x + lmd.x_offset + 1 + lmd.pf.move_x_dir
            elseif (lmd.x + lmd.x_offset + lmd.pf.move_x_dir + 1 > lmd.map_x_end) then
                lmd.map_x_end = lmd.x + lmd.x_offset + 1 + lmd.pf.move_x_dir
            end
            print("new boundaries", lmd.map_x_start, lmd.map_y_start, lmd.map_x_end, lmd.map_y_end)

            if (lmd.local_map[lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir] == nil) then -- if the new row is nil
                lmd.local_map[lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir] = {}
            end

            lmd.local_map[lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir][lmd.x + lmd.x_offset + 1 + lmd.pf.move_x_dir] = 2

            return 2 -- indicate failed move
        else
            return 3 -- indicate failed to move for reasons unrelated to map
        end
    end
end

lmd.pf.save_map = function(map_id)

    print("saving local map data to "..string.format("./navigator/map_cache/%d.lua", (map_id)))

    -- saves the map to a file
    export_data = {
        map = lmd.local_map,
        map_x_start = lmd.map_x_start,
        map_x_end = lmd.map_x_end,
        map_y_start = lmd.map_y_start,
        map_y_end = lmd.map_y_end,
        y_offset = lmd.y_offset,
        x_offset = lmd.x_offset
    }
    table.save(export_data, string.format("./navigator/map_cache/%d.lua", (map_id)))
end

lmd.pf.find_heuristic_cost = function(node_x, node_y, dest_x, dest_y)
    return math.sqrt((node_x - dest_x) ^ 2 + (node_y - dest_y) ^ 2)
end

lmd.pf.evaluate_neighbors = function(dest_x, dest_y, given_node)
    local neighbors = {}

    neighbor_insert = function(insert_x, insert_y)
        -- if the row doesn't exist
        -- or if the row exists, and the element does not equal an unmovable space
        if ((lmd.local_map[insert_y] == nil) or
            (lmd.local_map[insert_y] ~= nil and lmd.local_map[insert_y][insert_x] ~= 2)) then

            -- if the neighbor is an npc
            npc_bool = lmd.is_npc_at(insert_x, insert_y)

            if not npc_bool then

                h_cost = lmd.pf.find_heuristic_cost(insert_x, insert_y, dest_x, dest_y)

                -- if it's not a warp
                if lmd.local_map[insert_y] == nil or lmd.local_map[insert_y][insert_x] ~= 3 or h_cost < 0.01 then

                    local new_node_path = nil
                    if #given_node[3] == 0 then
                        new_node_path = {{insert_x, insert_y}}
                    else
                        -- print("given_node[3]:", given_node[3])
                        -- if #given_node[3] > 500 then
                        --     print("too many in given_node path")
                        --     return
                        -- end
                        new_node_path = {unpack(given_node[3])}
                        table.insert(new_node_path, #new_node_path + 1, {insert_x, insert_y})
                    end

                    -- the reason for this loop is to find the ideal place to insert neighbor
                    -- you want the best nodes to have highest indexes on the stack
                    i = 1
                    while i < #neighbors + 1 and h_cost + #new_node_path < #neighbors[i][3] + neighbors[i][4] do
                        i = i + 1
                    end

                    table.insert(neighbors, i, {insert_x, insert_y, new_node_path, h_cost})

                end

            end
        end

    end

    neighbor_insert(given_node[1] + 1, given_node[2])
    neighbor_insert(given_node[1] - 1, given_node[2])
    neighbor_insert(given_node[1], given_node[2] + 1)
    neighbor_insert(given_node[1], given_node[2] - 1)

    return neighbors
end

lmd.pf.find_path = function(dest_x, dest_y)
    print("find path, destination: ", dest_x, dest_y)
    -- print("starting stack:", {{lmd.x_offset + lmd.x + 1, lmd.y_offset + lmd.y + 1, {}, 1}})
    -- print("current boundaries: ", lmd.map_x_start, lmd.map_y_start, lmd.map_x_end, lmd.map_y_end)
    -- print("first neighbors: ", lmd.pf.evaluate_neighbors(dest_x, dest_y, {lmd.x_offset + lmd.x + 1, lmd.y_offset + lmd.y + 1, {}, 1}))
    local stack = {{lmd.x_offset + lmd.x + 1, lmd.y_offset + lmd.y + 1, {}, 1}} -- create stack using current player position
    -- local example_node = { x, y, { -- previous nodes -- }, heuristic_cost }

    -- the x, y or node 1 would be visited_nodes_x[1], visited_nodes_y[1]
    -- a node is visited when it has been added to queue
    local visited_nodes_x = {} -- tracks the visited x-coordinates
    local visited_nodes_y = {} -- tracks the visited y-coordinates

    -- Create a loop that goes through stack. Each iteration, look at the top node, 
    -- rank its available options using a cost function, then add those to the stack best nodes on top.
    
    while #stack > 0 do


        print("")
        print("stack", stack)
        print("visited_nodes_x", visited_nodes_x)
        print("visited_nodes_y", visited_nodes_y)

        -- get top element of stack
        local current_node = stack[#stack]

        if (current_node[4] < 0.01) then
            for i = #current_node[3], 1, -1 do
                table.insert(lmd.pf.path, (current_node[3][i]))
            end
            break
        end

        -- find neighbors of element
        local current_node_neighbors = lmd.pf.evaluate_neighbors(dest_x, dest_y, current_node)
        
        -- remove top element of stack
        table.remove(stack)

        -- add neighbors to stack
        for _, node in pairs(current_node_neighbors) do

            -- makes sure we haven't alrady checked this node
            has_been_visited = false
            for check_index, checking_x in pairs(visited_nodes_x) do
                if (checking_x == node[1] and visited_nodes_y[check_index] == node[2]) then
                    has_been_visited = true
                    break
                end
            end

            if not has_been_visited then
                table.insert(stack, #stack + 1, node)
                table.insert(visited_nodes_x, #visited_nodes_x + 1, node[1])
                table.insert(visited_nodes_y, #visited_nodes_y + 1, node[2])
            end
        end

    end
end

lmd.pf.follow_path = function()
    -- At any point if we’re unsure about the status (walking or blocked), 
    -- attempt to traverse it and if the tile is traversable restart algorithm.

    if not lmd.pf.ismoving then
        
        dir_x = lmd.pf.path[#lmd.pf.path][1] - (lmd.x_offset + lmd.x + 1)
        dir_y = lmd.pf.path[#lmd.pf.path][2] - (lmd.y_offset + lmd.y + 1)

        lmd.pf.try_move_start(dir_x, dir_y)

    else
        -- try_move can return 
        -- 0: successfully moved to destination
        -- 1: has not completed move
        -- 2: unknown obstacle blocked path
        -- 3: npc blocked path
        -- 4: player changed maps

        move_result = lmd.pf.try_move()
        if move_result == 0 then
            lmd.pf.ismoving = false
            lmd.pf.frame_counter = 0
            table.remove(lmd.pf.path)
            return 0 -- indicates complete move
        elseif move_result == 1 then
            return 1 -- indicates incomplete
        elseif move_result == 2 then
            lmd.pf.ismoving = false
            lmd.pf.frame_counter = 0
            lmd.pf.path = {}
            return 3 -- indicates move failed
        elseif move_result == 3 then
            lmd.pf.ismoving = false
            lmd.pf.frame_counter = 0
            lmd.pf.path = {}
        elseif move_result == 4 then
            lmd.pf.ismoving = false
            lmd.pf.path = {}
            lmd.pf.frame_counter = 0

            lmd.pf.is_warping = true
            lmd.pf.warp_frame_counter = 0
            return 2 -- indicates warp
        end
    end
end

lmd.pf.load_map = function()
    if lmd.map_id~=mem.get_map() then
        lmd.map_id = mem.get_map()
        lmd.wander_to = nil
		lmd.pf.trying_to_warp_counter = 0
    
        -- first check to see if the map is already stored somewhere
        print("changing offsets in load_map, before", lmd.x_offset, lmd.y_offset)

        
        saved_map = io.open(string.format("./navigator/map_cache/%d.lua", (lmd.map_id)), "r")
        if saved_map ~= nil then
            saved_map:close()
    
            import_data = table.load(string.format("./navigator/map_cache/%d.lua", (lmd.map_id)))
    
            lmd.local_map = import_data.map
            lmd.map_x_start = import_data.map_x_start
            lmd.map_x_end = import_data.map_x_end
            lmd.map_y_start = import_data.map_y_start
            lmd.map_y_end = import_data.map_y_end
            lmd.y_offset = import_data.y_offset
            lmd.x_offset = import_data.x_offset
            
            print("imported map data: ", import_data)
        else
            print("calling reset_map from load_map")
            lmd.reset_map()
        end


        print("after", lmd.x_offset, lmd.y_offset)
    end
end

local function manage_warp()
    if lmd.pf.warp_frame_counter < lmd.pf.warp_frames_per_warp then
        lmd.pf.warp_frame_counter = lmd.pf.warp_frame_counter + 1
    else
        lmd.pf.load_map()
        lmd.pf.is_warping = false
    end
end

lmd.pf.manage_path_to = function(dest_x, dest_y)

    if #lmd.pf.path == 0 then
        
        if lmd.x + lmd.x_offset + 1 == dest_x and lmd.y + lmd.y_offset + 1 == dest_y then
            return 1 -- indicates player is at destination
        end

        if lmd.pf.is_warping then
            manage_warp()
        else
            lmd.pf.find_path(dest_x, dest_y)    
        end
    else
        -- lmd.pf.follow_path can return:
        -- 0: still working on path
        -- 1: completed path
        -- 2: global map has changed

        follow_path_res = lmd.pf.follow_path()

        if follow_path_res == 2 then
            return 2 -- indicates player has warped 
        elseif follow_path_res == 3 then
            return 3 -- indicates player has attempted and failed move
        end
    end

    return 0 -- indicates destination has not been reached
end

lmd.pf.abs_manage_path_to = function(dest_x, dest_y)
    return lmd.pf.manage_path_to(dest_x + lmd.x_offset + 1, dest_y + lmd.y_offset + 1)
end

lmd.gpf = { -- global pathfinder
    current_path = nil
}

-- secondary_to_map is for pokemon centers, like 
-- if we're okay with reaching either to_map or another
-- map, whichever we find first
lmd.gpf.find_global_path = function(to_map, to_x, to_y, secondary_to_map)
    if not lmd.pf.ismoving then 
        -- print("called load map in find_global_path")
        lmd.pf.load_map() 
    end
    -- print("finding global path from:", lmd.map_id, lmd.x, lmd.y)
    if lmd.map_id == to_map or (secondary_to_map ~= nil and lmd.map_id == secondary_to_map) then
            -- print("target same map as current, go to: ", to_x, to_y)
            lmd.gpf.current_path = {{to_x, to_y}}
        return true
    else
        -- print("current map: ", lmd.map_id)
        -- print("target map: ", to_map)
        -- print("current g_map:", gmd.map)
        global_pathfinding_res = gmd.go_to_map(lmd.map_id, lmd.x, lmd.y, to_map, secondary_to_map)
        -- print("path: ", global_pathfinding_res)
        if global_pathfinding_res then
            lmd.gpf.current_path = {unpack(global_pathfinding_res), {to_x, to_y}}
            return true
        else
            return false
        end
    end
end

lmd.wander_to = nil

lmd.wander = function() -- the point of this function is to expand the bot's knowledge of the map

    if lmd.pf.is_warping then
        manage_warp()
        return nil
    end

    if lmd.local_map[lmd.y_offset + lmd.y + 1] and lmd.local_map[lmd.y_offset + lmd.y + 1][lmd.x_offset + lmd.x+1] == nil then
        print("set", lmd.x_offset + lmd.x+1, lmd.y_offset + lmd.y + 1, "to 1")
        lmd.local_map[lmd.y_offset + lmd.y + 1][lmd.x_offset + lmd.x+1] = 1
    end

    if lmd.wander_to == nil then
        -- print("wander to nil, gmd.fully_explored[lmd.map_id]", gmd.fully_explored[lmd.map_id])
        if gmd.fully_explored[lmd.map_id] == true then

            if gmd.map[lmd.map_id] ~= nil then
                local queue = {lmd.map_id}
                local added_to_queue = {lmd.map_id}

                while #queue ~= 0 do
                    
                    -- print("")
                    -- print("queue", queue)
                    -- print("added_to_queue", added_to_queue)

                    for _, warp in pairs(gmd.map[queue[1]]) do
                        if not (gmd.fully_explored[warp[1]]) then
                            -- print("calling abs_manage_path_to from wander with args", warp[2], warp[3])
                            if (lmd.gpf.current_path == nil) then lmd.gpf.find_global_path(warp[1], warp[2], warp[3]) end
                            lmd.pf.abs_manage_path_to(unpack(lmd.gpf.current_path[1]))
                            return
                        else
                            local has_node_been_visited = false
                            for _, visited_map in pairs(added_to_queue) do
                                if visited_map == warp[1] then
                                    has_node_been_visited = true
                                    break
                                end
                            end
                            
                            if not has_node_been_visited then 
                                table.insert(queue, warp[1])
                            end
                        end
                    end

                    table.insert(added_to_queue, queue[1])
                    table.remove(queue, 1)
                end
            else
                print("current map not found in global")
            end

        else
            if lmd.local_map[lmd.y + lmd.y_offset + 1] ~= nil then
                if lmd.local_map[lmd.y + lmd.y_offset + 1][lmd.x + lmd.x_offset + 1] == 3 then
                    print("standing on warp: lmd.local_map[", lmd.y + lmd.y_offset + 1, "][", lmd.x + lmd.x_offset + 1, "] =", lmd.local_map[lmd.y + lmd.y_offset + 1][lmd.x + lmd.x_offset + 1])
					
					-- this means the warp failed
					if lmd.pf.trying_to_warp_counter > lmd.pf.trying_to_warp_limit then
						lmd.local_map[lmd.y + lmd.y_offset + 1][lmd.x + lmd.x_offset + 1] = 1
					else
						lmd.pf.trying_to_warp_counter = lmd.pf.trying_to_warp_counter + 1
					end
                    
					return
                end 
            end
            print("starting to find wander path")
            queue = {}

            -- gives starting node
            table.insert(queue, {lmd.x + lmd.x_offset + 1, lmd.y + lmd.y_offset + 1})

			-- lists all nodes ever added to queue.
			-- does not necessarily mean it's neighbors
			-- have been have been added, which I
			-- get is kind of misleading
            visited_nodes = {} 

            function insert_node(insert_x, insert_y)
                -- print("wander: insert node: ", {insert_x, insert_y})

                -- if the computer has already visited this node
                if debug_key then
                    print(insert_x, insert_y)
                end
                if visited_nodes[insert_x] ~= nil and visited_nodes[insert_x][insert_y] then
                    return 0
                end

                -- print("before called is_npc")
                npc_bool = lmd.is_npc_at(insert_x, insert_y)
                if npc_bool then
                    return 0
                end
                -- print("after called is_npc")

                -- if this neighbor is unknown
                if (lmd.local_map[insert_y] == nil or (lmd.local_map[insert_y][insert_x] == nil)) then
                    lmd.wander_to = {insert_x, insert_y}
                    return 1
                end

                -- if it's not a warp or a unmovable tile
                if ((lmd.local_map[insert_y][insert_x] ~= 2 and lmd.local_map[insert_y][insert_x] ~= 3)) then
                    table.insert(queue, {insert_x, insert_y})
                end

				if (visited_nodes[insert_x] == nil) then
                    visited_nodes[insert_x] = {}
                end
                visited_nodes[insert_x][insert_y] = true

                return 0
            end

            while #queue > 0 do

                -- if ( debug_key ) then
					-- print("current_node", queue[1])
                    -- print('queue', queue)
                    -- print('visited nodes', visited_nodes)
					-- print("")

                -- end

                current_node = queue[1]
                -- print("wander, current node: ", current_node)

                has_found_blank_tile = 0

                if has_found_blank_tile < 1 then
                    has_found_blank_tile = has_found_blank_tile + insert_node(current_node[1], current_node[2] + 1)
                end

                if has_found_blank_tile < 1 then
                    has_found_blank_tile = has_found_blank_tile + insert_node(current_node[1] - 1, current_node[2])
                end

                if has_found_blank_tile < 1 then
                    has_found_blank_tile = has_found_blank_tile + insert_node(current_node[1], current_node[2] - 1)
                end
                
                if has_found_blank_tile < 1 then
                    has_found_blank_tile = has_found_blank_tile + insert_node(current_node[1] + 1, current_node[2])
                end

                if has_found_blank_tile > 0 then
                    return
                end

                -- if (visited_nodes[current_node[1]] == nil) then
                --     visited_nodes[current_node[1]] = {}
                -- end
                -- visited_nodes[current_node[1]][current_node[2]] = true

                table.remove(queue, 1)
            end

            if lmd.wander_to == nil then
                gmd.fully_explored[lmd.map_id] = true
                print("gmd.fully_explored[lmd.map_id] = true")
            else
                print("wander to ", lmd.wander_to)
            end
        end
    else
        -- print("wander_to != nil")
        manage_path_res = lmd.pf.manage_path_to(unpack(lmd.wander_to))

        -- print("wander: manage_path_res: ", manage_path_res)

        if (manage_path_res == 1 or manage_path_res == 3) then
            lmd.wander_to = nil
        end
    end
end

lmd.get_global_map_data = function()
    return {fully_explored = gmd.fully_explored, map = gmd.map}
end

lmd.set_global_map_data = function(data)
    gmd.fully_explored = data.fully_explored
    gmd.map = data.map
    -- print("set global map data to: ", gmd.fully_explored, gmd.map)
end

function lmd.reset_map()
    -- print("inside reset map")

    lmd.local_map = {{nil}}
    lmd.map_x_start = 1
    lmd.map_x_end = 1
    lmd.map_y_start = 1
    lmd.map_y_end = 1
    lmd.x, lmd.y = mem.get_pos()
    lmd.y_offset = -lmd.y
    lmd.x_offset = -lmd.x
end

function lmd.is_npc_at(grid_x, grid_y) -- x, y are indexes on local_map
    ingame_y = grid_y - lmd.y_offset - 1
    ingame_x = grid_x - lmd.x_offset - 1

    if (ingame_x == lmd.x and ingame_y == lmd.y) then
        return false
    end

    editat, count = mem.get_npc_mem()

    for i = 0, count - 1 do
        x_addr = editat + 227 * 0x24 - 2 + 16 * (14 + 16 * i)
        -- y_addr = x_addr + 8
        if (memory.readword(x_addr) == ingame_x and memory.readword(x_addr + 8) == ingame_y) then
            return true
        end
    end
    return false
end

function lmd.debug_map_view()

    if lmd.pf.is_warping then
        return
    end
    -- print(lmd.map_y_start, lmd.map_y_end, lmd.map_x_start, lmd.map_x_end)
    for i = lmd.map_y_start, lmd.map_y_end do -- goes through all the rows

        if math.abs(lmd.y + lmd.y_offset - (i - 1)) < lmd.vertical_limit then
            for j = lmd.map_x_start, lmd.map_x_end do -- goes through all the columns in the row
                if math.abs(lmd.x + lmd.x_offset - (j - 1)) < lmd.horizontal_limit then
                    if lmd.local_map == nil then
                        print("debug_map: error in map, here's the map and the search coordinates: ", lmd.local_map, i, j)
                        lmd.pf.load_map()
                        return
                    end
                    if lmd.local_map[i] == nil then
                        lmd.local_map[i] = {}
                    end
                    node_type = lmd.local_map[i][j]
                    color = {}
        
                    if (node_type ~= nil) then
                        if node_type == 1 then
                            color = {255, 255, 255, 255}
                        elseif node_type == 2 then
                            color = {0, 0, 0, 255}
                        elseif node_type == 3 then
                            color = {0, 0, 255, 255}
                        else
                            print("strange nodetype detected: " .. node_type)
                            color = {255, 192, 203, 255}
                        end
        
                        y_alt = lmd.debug_box_margin * (lmd.y + lmd.y_offset - (i - 1))
        
                        if 90 - lmd.debug_box_size - y_alt > 0 then
                            x_alt = lmd.debug_box_margin * (lmd.x + lmd.x_offset - (j - 1))
                            gui.box(128 - lmd.debug_box_size - x_alt, 90 - lmd.debug_box_size - y_alt,
                                128 + lmd.debug_box_size - x_alt, 90 + lmd.debug_box_size - y_alt, color, {255, 255, 255, 255})
                        end
        
                    end
                end
    
            end
        end
    end
end

function lmd.debug_npc_view()
    editat, count = mem.get_npc_mem()

    for i = 0, count - 1 do
        x_addr = editat + 227 * 0x24 - 2 + 16 * (14 + 16 * i)
        -- y_addr = x_addr + 8

        y_alt = lmd.debug_box_margin * (lmd.y - (memory.readword(x_addr + 8)))

        if 90 - lmd.debug_box_size - y_alt > 0 then

            x_alt = lmd.debug_box_margin * (lmd.x - (memory.readword(x_addr)))
            if (x_alt ~= 0 or y_alt ~= 0) then
                gui.box(128 - lmd.debug_box_size - x_alt, 90 - lmd.debug_box_size - y_alt,
                    128 + lmd.debug_box_size - x_alt, 90 + lmd.debug_box_size - y_alt, {0, 255, 0, 255},
                    {255, 255, 255, 255})
            end
        end

    end
end

function lmd.debug_player_view()

    gui.box(128 - lmd.debug_box_size, 90 - lmd.debug_box_size, 128 + lmd.debug_box_size, 90 + lmd.debug_box_size,
        {255, 0, 0, 255}, {255, 255, 255, 255})

end

function lmd.update_map(debug_map) -- boolean debug_map decides whether or not to render map

    lmd.x, lmd.y = mem.get_pos()
    if lmd.map_id ~= mem.get_map() then -- if the map has changed
        if lmd.map_id == nil then
            print("load_map called from update_map")
            lmd.pf.load_map()
        end
    end

    if debug_map then
        lmd.debug_map_view()
        lmd.debug_npc_view()
        lmd.debug_player_view()
        gui.text(1, 30, "rel:" .. tostring(lmd.x + lmd.x_offset + 1))
        gui.text(46, 30, "rel:" .. tostring(lmd.y + lmd.y_offset + 1))
        gui.text(1, 50, lmd.x)
        gui.text(46, 50, lmd.y)
        gui.text(1, 70, string.format("Map ID: %s", mem.get_map()))
    end
end

return lmd
