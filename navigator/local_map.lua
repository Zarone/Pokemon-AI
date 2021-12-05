local mem = require "memory_retrieval"

local x = nil
local y = nil
-- local z = nil
local map_id = nil

-- 0 is players location -- red
-- 1 is movable space -- white
-- 2 is unmovable space -- black
-- 3 is warp space -- blue
-- 4 is NPC -- green
local local_map = {{0}}
local map_x_start = 1
local map_x_end = 1
local map_y_start = 1
local map_y_end = 1

-- local_map[y_offset + y+1][x_offset + x+1] = the location of the player on the local map
local x_offset = 0
local y_offset = 0

local debug_map = true
local debug_box_size = 4
local debug_box_margin = 10

function reset_map()
    local_map = {{0}}
    map_x_start = 1
    map_x_end = 1
    map_y_start = 1
    map_y_end = 1
end

local pf = { -- pathfinder
    ismoving = true,
    frame_counter = 0,
    frame_per_move = 30
    -- frame_per_stop = 5
}

pf.try_move_start = function()
    pf.last_x = x
    pf.last_y = y
    print("start move")
end

pf.try_move = function(dir_x, dir_y) -- arguments are either (-1, 0), (0, -1), (0, 1) or (1, 0)
    -- if not pathfinder.ismoving then
    -- print("start moving", pathfinder.frame_counter, pathfinder.frame_per_move)

    if (pf.ismoving) then
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

        if not (pf.last_x == x and pf.last_y == y) then
            -- moved successfully
            pf.ismoving = false
        elseif pf.frame_counter > pf.frame_per_move then
            -- moved unsucessfully

            -- expand the map
            if (y + y_offset + 1 + dir_y < map_y_start) then
                map_y_start = y + y_offset + 1 + dir_y
            elseif (y + y_offset + 1 + dir_y > map_y_end) then
                map_y_end = y + y_offset + 1 + dir_y
            end

            if (x + x_offset + 1 + dir_x < map_x_start) then
                map_x_start = x + x_offset + 1 + dir_x
            elseif (x + x_offset + dir_x + 1 > map_x_end) then
                map_x_end = x + x_offset + 1 + dir_x
            end

            if (local_map[y + y_offset + 1 + dir_y] == nil) then -- if the new row is nil
                local_map[y + y_offset + 1] = {}
            end
            local_map[y + y_offset + 1 + dir_y][x + x_offset + 1 + dir_x] = 2

            pf.ismoving = false
        end

        pf.frame_counter = pf.frame_counter + 1
    end
end

function is_npc_at(grid_x, grid_y) -- x, y are indexes on local_map
    ingame_y = grid_y - y_offset + 1
    ingame_x = grid_x - x_offset + 1

    if (ingame_x == x and ingame_y == y) then
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

function debug_map_view()
    for i = map_y_start, map_y_end do -- goes through all the rows 
        for j = map_x_start, map_x_end do -- goes through all the columns in the row

            node_type = local_map[i][j]
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

                x_alt = debug_box_margin * (x + x_offset - (j - 1))
                y_alt = debug_box_margin * (y + y_offset - (i - 1))
                gui.box(128 - debug_box_size - x_alt, 90 - debug_box_size - y_alt, 128 + debug_box_size - x_alt,
                    90 + debug_box_size - y_alt, color, {255, 255, 255, 255})

            end
        end
    end
end

function debug_npc_view()
    editat, count = mem.get_npc_mem()

    for i = 0, count - 1 do
        x_addr = editat + 227 * 0x24 - 2 + 16 * (14 + 16 * i)
        -- y_addr = x_addr + 8

        x_alt = debug_box_margin * (x - (memory.readword(x_addr)))
        y_alt = debug_box_margin * (y - (memory.readword(x_addr + 8)))
        if (x_alt ~= 0 or y_alt ~= 0) then
            gui.box(128 - debug_box_size - x_alt, 90 - debug_box_size - y_alt, 128 + debug_box_size - x_alt,
                90 + debug_box_size - y_alt, {0, 255, 0, 255}, {255, 255, 255, 255})
        end
    end
end

local temp = true
while true do
    old_x = x
    old_y = y

    x, y = mem.get_pos()
    if map_id ~= mem.get_map() then -- if the map has changed
        print("new map")

        -- first check to see if the map is already stored somewhere
        -- if not make a new offset x and y
        reset_map()
        y_offset = -y
        x_offset = -x

        map_id = mem.get_map()
    elseif x ~= old_x or y ~= old_y then -- if the user moved
        -- print("moved")

        x, y = mem.get_pos()

        -- set the last location to movable space
        if old_x ~= nil then
            local_map[old_y + y_offset + 1][old_x + x_offset + 1] = 1
        end

        -- expand the map
        if (y + y_offset + 1 < map_y_start) then
            map_y_start = y + y_offset + 1
        elseif (y + y_offset + 1 > map_y_end) then
            map_y_end = y + y_offset + 1
        end

        if (x + x_offset + 1 < map_x_start) then
            map_x_start = x + x_offset + 1
        elseif (x + x_offset + 1 > map_x_end) then
            map_x_end = x + x_offset + 1
        end

        if (y ~= old_y) then -- if the y changed
            if (local_map[y + y_offset + 1] == nil) then -- if the new row is nil
                local_map[y + y_offset + 1] = {}
            end
            local_map[y + y_offset + 1][x + x_offset + 1] = 0
        end

        if (x ~= old_x) then -- if the x changed
            local_map[y + y_offset + 1][x + x_offset + 1] = 0
        end
    end

    if debug_map then
        debug_map_view()
        debug_npc_view()
    end

    if temp then
        pf.try_move_start()
        temp = false
    end
    pf.try_move(1, 0)

    emu.frameadvance()
end
