local lmd = {} -- local map data

mem = require "memory_retrieval"

lmd.x = nil
lmd.y = nil
-- lmd.z = nil
lmd.map_id = nil

-- 0 is players location -- red
-- 1 is movable space -- white
-- 2 is unmovable space -- black
-- 3 is warp space -- blue
-- 4 is NPC -- green
lmd.local_map = {{0}}
lmd.map_x_start = 1
lmd.map_x_end = 1
lmd.map_y_start = 1
lmd.map_y_end = 1

-- local_map[y_offset + y+1][x_offset + x+1] = the location of the player on the local map
lmd.x_offset = 0
lmd.y_offset = 0

-- local debug_map = true
lmd.debug_box_size = 3
lmd.debug_box_margin = 8

lmd.pf = { -- pathfinder
    path = {},
    ismoving = false,
    move_x_dir = nil,
    move_y_dir = nil,
    frame_counter = 0,
    frame_per_move = 30
}

lmd.pf.try_move_start = function(dir_x, dir_y)
    lmd.pf.last_x = lmd.x
    lmd.pf.last_y = lmd.y
    lmd.pf.ismoving = true
    lmd.pf.move_x_dir = dir_x
    lmd.pf.move_y_dir = dir_y
    -- print("start move")
end

lmd.pf.try_move = function() -- arguments are either (-1, 0), (0, -1), (0, 1) or (1, 0)
    -- if not pathfinder.ismoving then
    -- print("start moving", pathfinder.frame_counter, pathfinder.frame_per_move)

    dir = {}

    if (lmd.pf.move_x_dir == 0 and lmd.pf.move_y_dir == -1) then
        dir.up = true
    elseif (lmd.pf.move_x_dir == 0 and lmd.pf.move_y_dir == 1) then
        dir.down = true
    elseif (lmd.pf.move_x_dir == 1 and lmd.pf.move_y_dir == 0) then
        dir.right = true
    elseif (lmd.pf.move_x_dir == -1 and lmd.pf.move_y_dir == 0) then
        dir.left = true
    end

    joypad.set(0, dir)

    if not (lmd.pf.last_x == lmd.x and lmd.pf.last_y == lmd.y) then
        -- moved successfully
        return 0
    elseif lmd.pf.frame_counter > lmd.pf.frame_per_move then
        -- moved unsucessfully

        if not (lmd.is_npc_at(lmd.x + lmd.x_offset + lmd.pf.move_x_dir, lmd.y + lmd.y_offset + lmd.pf.move_y_dir)) then

            print("no npc found at: ", lmd.x + lmd.x_offset + lmd.pf.move_x_dir,
                lmd.y + lmd.y_offset + lmd.pf.move_y_dir)

            -- expand the map
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

            if (lmd.local_map[lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir] == nil) then -- if the new row is nil
                lmd.local_map[lmd.y + lmd.y_offset + 1] = {}
            end
            -- print(lmd.local_map, lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir)
            lmd.local_map[lmd.y + lmd.y_offset + 1 + lmd.pf.move_y_dir][lmd.x + lmd.x_offset + 1 + lmd.pf.move_x_dir] = 2
            return 2
        end

        return 3
    end

    lmd.pf.frame_counter = lmd.pf.frame_counter + 1
    return 1
end

lmd.pf.find_heuristic_cost = function(node_x, node_y, dest_x, dest_y)
    return math.sqrt((node_x - dest_x) ^ 2 + (node_y - dest_y) ^ 2)
end

lmd.pf.evaluate_neighbors = function(dest_x, dest_y, given_node)
    neighbors = {}

    neighbor_insert = function(insert_x, insert_y)
        -- if the row doesn't exist
        -- or if the row exists, and the element does not equal an unmovable space
        if ((lmd.local_map[insert_y] == nil) or
            (lmd.local_map[insert_y] ~= nil and lmd.local_map[insert_y][insert_x] ~= 2)) then

            -- if the neighbor is without an npc
            npc_bool = lmd.is_npc_at(insert_x, insert_y)

            if not npc_bool then

                h_cost = lmd.pf.find_heuristic_cost(insert_x, insert_y, dest_x, dest_y)

                new_node_path = nil
                if #given_node[3] == 0 then
                    new_node_path = {{insert_x, insert_y}}
                else
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

    neighbor_insert(given_node[1], given_node[2] + 1)
    neighbor_insert(given_node[1], given_node[2] - 1)
    neighbor_insert(given_node[1] + 1, given_node[2])
    neighbor_insert(given_node[1] - 1, given_node[2])

    return neighbors
end

lmd.pf.find_path = function(dest_x, dest_y)
    stack = {{lmd.x_offset + lmd.x + 1, lmd.y_offset + lmd.y + 1, {}, 1}} -- create stack
    -- local example_node = { x, y, { -- previous nodes -- }, heuristic_cost }

    -- the x, y or node 1 would be visited_nodes_x[1], visited_nodes_y[1]
    -- a node is visited when it has been added to queue
    visited_nodes_x = {} -- tracks the visited x-coordinates
    visited_nodes_y = {} -- tracks the visited y-coordinates

    -- Create a loop that goes through stack. Each iteration, look at the top node, 
    -- rank its available options using a cost function, then add those to the stack best nodes on top.

    while #stack > 0 do

        -- get top element of stack
        current_node = stack[#stack]

        if (current_node[4] < 0.01) then
            print("final node: ", current_node)
            for i = #current_node[3], 1, -1 do
                table.insert(lmd.pf.path, (current_node[3][i]))
            end
            break
        end

        -- find neighbors of element
        current_node_neighbors = lmd.pf.evaluate_neighbors(dest_x, dest_y, current_node)

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

        move_result = lmd.pf.try_move()
        if move_result == 0 then
            lmd.pf.ismoving = false
            lmd.pf.frame_counter = 0
            table.remove(lmd.pf.path)
        elseif move_result == 1 then
            return
        elseif move_result == 2 then
            lmd.pf.ismoving = false
            lmd.pf.frame_counter = 0
            lmd.pf.path = {}
        elseif move_result == 3 then
            lmd.pf.ismoving = false
            lmd.pf.frame_counter = 0
            lmd.pf.path = {}
        end
    end
end

lmd.pf.manage_path_to = function(dest_x, dest_y)
    if lmd.x+lmd.x_offset+1 == dest_x and lmd.y+lmd.y_offset+1 == dest_y  then
        print("at destination")
        return
    else 
        if #lmd.pf.path == 0 then
            print("finding new path")
            lmd.pf.find_path(dest_x, dest_y)
        else
            -- print("following path: ", lmd.pf.path)
            lmd.pf.follow_path()
        end
    end
end

function lmd.reset_map()
    lmd.local_map = {{0}}
    lmd.map_x_start = 1
    lmd.map_x_end = 1
    lmd.map_y_start = 1
    lmd.map_y_end = 1
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
    for i = lmd.map_y_start, lmd.map_y_end do -- goes through all the rows 
        for j = lmd.map_x_start, lmd.map_x_end do -- goes through all the columns in the row

            node_type = lmd.local_map[i][j]
            color = {}

            if (node_type ~= nil) then
                if node_type == 0 then
                    color = {255, 0, 0, 255}
                elseif node_type == 1 then
                    color = {255, 255, 255, 255}
                elseif node_type == 2 then
                    color = {0, 0, 0, 255}
                elseif node_type == 3 then
                    color = {0, 0, 255, 255}
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

function lmd.update_map(debug_map) -- boolean debug_map decides whether or not to render map
    old_x = lmd.x
    old_y = lmd.y

    lmd.x, lmd.y = mem.get_pos()
    if lmd.map_id ~= mem.get_map() then -- if the map has changed
        print("new map")

        -- first check to see if the map is already stored somewhere
        -- if not make a new offset x and y
        lmd.reset_map()
        lmd.y_offset = -lmd.y
        lmd.x_offset = -lmd.x

        lmd.map_id = mem.get_map()
    elseif lmd.x ~= old_x or lmd.y ~= old_y then -- if the user moved
        -- print("moved")

        lmd.x, lmd.y = mem.get_pos()

        -- set the last location to movable space
        if old_x ~= nil then
            lmd.local_map[old_y + lmd.y_offset + 1][old_x + lmd.x_offset + 1] = 1
        end

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

        if (lmd.y ~= old_y) then -- if the y changed
            if (lmd.local_map[lmd.y + lmd.y_offset + 1] == nil) then -- if the new row is nil
                lmd.local_map[lmd.y + lmd.y_offset + 1] = {}
            end
            lmd.local_map[lmd.y + lmd.y_offset + 1][lmd.x + lmd.x_offset + 1] = 0
        end

        if (lmd.x ~= old_x) then -- if the x changed
            lmd.local_map[lmd.y + lmd.y_offset + 1][lmd.x + lmd.x_offset + 1] = 0
        end
    end

    if debug_map then
        lmd.debug_map_view()
        lmd.debug_npc_view()
        gui.text(1, 30, lmd.x+lmd.x_offset+1)
        gui.text(11, 30, lmd.y+lmd.y_offset+1)
    end
end

return lmd
