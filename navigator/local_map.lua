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
    ismoving = true,
    frame_counter = 0,
    frame_per_move = 30
}

lmd.pf.try_move_start = function()
    lmd.pf.last_x = lmd.x
    lmd.pf.last_y = lmd.y
    print("start move")
end

lmd.pf.try_move = function(dir_x, dir_y) -- arguments are either (-1, 0), (0, -1), (0, 1) or (1, 0)
    -- if not pathfinder.ismoving then
    -- print("start moving", pathfinder.frame_counter, pathfinder.frame_per_move)

    if (lmd.pf.ismoving) then
        dir = {}

        if (dir_x == 0 and dir_y == 1) then
            dir.up = true
        elseif (dir_x == 0 and dir_y == -1) then
            dir.down = true
        elseif (dir_x == 1 and dir_y == 0) then
            dir.right = true
        elseif (dir_x == -1 and dir_y == 0) then
            dir.left = true
        end

        joypad.set(0, dir)

        if not (lmd.pf.last_x == lmd.x and lmd.pf.last_y == lmd.y) then
            -- moved successfully
            lmd.pf.ismoving = false
        elseif lmd.pf.frame_counter > lmd.pf.frame_per_move then
            -- moved unsucessfully

            if not (lmd.is_npc_at(lmd.x + lmd.x_offset + dir_x, lmd.y + lmd.y_offset + dir_y)) then

                print("no npc found at: ", lmd.x + lmd.x_offset + dir_x, lmd.y + lmd.y_offset + dir_y)

                -- expand the map
                if (lmd.y + lmd.y_offset + 1 + dir_y < lmd.map_y_start) then
                    lmd.map_y_start = lmd.y + lmd.y_offset + 1 + dir_y
                elseif (lmd.y + lmd.y_offset + 1 + dir_y > lmd.map_y_end) then
                    lmd.map_y_end = lmd.y + lmd.y_offset + 1 + dir_y
                end

                if (lmd.x + lmd.x_offset + 1 + dir_x < lmd.map_x_start) then
                    lmd.map_x_start = lmd.x + lmd.x_offset + 1 + dir_x
                elseif (lmd.x + lmd.x_offset + dir_x + 1 > lmd.map_x_end) then
                    lmd.map_x_end = lmd.x + lmd.x_offset + 1 + dir_x
                end

                if (lmd.local_map[lmd.y + lmd.y_offset + 1 + dir_y] == nil) then -- if the new row is nil
                    lmd.local_map[lmd.y + lmd.y_offset + 1] = {}
                end
                lmd.local_map[lmd.y + lmd.y_offset + 1 + dir_y][lmd.x + lmd.x_offset + 1 + dir_x] = 2
            end

            lmd.pf.ismoving = false
        end

        lmd.pf.frame_counter = lmd.pf.frame_counter + 1
    end
end

function lmd.reset_map()
    lmd.local_map = {{0}}
    lmd.map_x_start = 1
    lmd.map_x_end = 1
    lmd.map_y_start = 1
    lmd.map_y_end = 1
end

lmd.pf.find_heuristic_cost = function(node_x, node_y, dest_x, dest_y)
    return math.sqrt((node_x - dest_x) ^ 2 + (node_y - dest_y) ^ 2)
end

lmd.pf.evaluate_neighbors = function(node_x, node_y, dest_x, dest_y, cost_of_current_node)
    neighbors = {}

    -- adjust this to insert at correct location

    if (lmd.local_map[node_y + 1] ~= nil) then
        table.insert(neighbors, {node_x, node_y + 1, cost_of_current_node + 1,
                                 lmd.pf.find_heuristic_cost(node_x, node_y + 1, dest_x, dest_y)})
    end

    return neighbors
end

lmd.pf.pathfind_start = function(dest_x, dest_y)
    stack = {} -- create stack
    -- local example_node = { x, y, literal_cost, heuristic_cost }

    -- Loop through accessible nodes from current point, 
    -- rank them based on heuristic distance and distance from starting position.
    -- Push them to stack, best nodes at the top

    -- Create a loop that goes through stack. Each iteration, look at the top node, rank its available options using a cost function, then add those to the stack best nodes on top.
    -- At any point if we’re unsure about the status (walking or blocked), attempt to traverse it and if the tile is traversable restart algorithm.

end

function lmd.is_npc_at(grid_x, grid_y) -- x, y are indexes on local_map
    ingame_y = grid_y - lmd.y_offset -- + 1
    ingame_x = grid_x - lmd.x_offset -- + 1

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
    end
end

return lmd
