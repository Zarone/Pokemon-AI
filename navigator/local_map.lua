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

function get_map()
    return memory.readword(0x0224F90C)
end

function get_pos()
    return memory.readword(0x0224F912, 2), memory.readword(0x0224F91A), memory.readword(0x0224F916)
end

function reset_map()
    local_map = {{0}}
    map_x_start = 1
    map_x_end = 1
    map_y_start = 1
    map_y_end = 1
end

function try_move(dir_x, dir_y) -- arguments are either (0, 1) or (1, 0)

end

function is_npc_at(grid_x, grid_y) -- x, y are indexes on local_map
    -- y + yoffset = gridy
    ingame_y = grid_y - y_offset
    ingame_x = grid_x - x_offset

    if memory.readbyteunsigned(0x023FFE09) == 0x00 then -- Not "2" ~ Not B2/W2
        ows = md(0x02000024) + 0x34E04
        game = 1
    else
        ows = md(0x02000024) + 0x36BE8
        game = 2
    end

    mode = 2
    editat = 0x08 + 5 * 0x14 + ows
    count = memory.readbyteunsigned(ows + 3 + mode)

    for i = 0, count-1
    do
        x_addr = editat + 227 * 0x24 - 2 + 16 * (14+16*i)
        -- y_addr = x_addr + 8
        print(memory.readword(x_addr), memory.readword(x_addr+8))
        -- gui.text(1, i*20+60, sf("%d", memory.readword(editat + 227 * 0x24 - 2 + 16 * (14+16*i))))
        -- gui.text(1, i*20+70, sf("%d", memory.readword(editat + 227 * 0x24 + 6 + 16 * (14+16*i))))
    end
end

while true do

    old_x = x
    old_y = y

    x, y = get_pos()
    if map_id ~= get_map() -- if the map has changed
    then
        print("new map")

        -- first check to see if the map is already stored somewhere
        -- if not make a new offset x and y
        reset_map()
        y_offset = -y
        x_offset = -x

        map_id = get_map()
    elseif x ~= old_x or y ~= old_y then -- if the user moved
        -- print("moved")

        x, y = get_pos()

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

        if (x ~= old_x) then
            local_map[y + y_offset + 1][x + x_offset + 1] = 0
        end
    end

    if debug_map then
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
                    elseif node_type == 4 then
                        color = {0, 255, 0, 255}
                    end

                    x_alt = 15 * (x + x_offset - (j - 1))
                    y_alt = 15 * (y + y_offset - (i - 1))
                    gui.box(123 - x_alt, 90 - y_alt, 133 - x_alt, 100 - y_alt, color, {255, 255, 255, 255})

                end
            end
        end
    end

    emu.frameadvance()
end
