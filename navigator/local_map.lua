local x = nil
local y = nil
-- local z = nil
local map_id = nil

-- local delta_time = 0
-- local wait_frames = 24

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

while true do
    -- delta_time = delta_time + 1

    old_x = x
    old_y = y

    -- if delta_time % wait_frames == 0 then
        x, y = get_pos()
        if map_id ~= get_map() -- if the map has changed
        then
            print("new map")
            
            -- first check to see if the map is already stored somewhere
            -- if not make a new offset x and y
            y_offset = -y
            x_offset = -x
            
            map_id = get_map()
        elseif x ~= old_x or y ~= old_y then
            -- print("moved")
            -- print(local_map)

            x, y = get_pos()
            if old_x ~= nil then
                local_map[old_y+y_offset+1][old_x+x_offset+1] = 1
            end
            
            -- print(local_map)


            -- print(local_map[y+y_offset+1])
            -- if local_map[y+y_offset] == nil then
            --     table.insert(local_map, y+y_offset+1, {0})
            -- end
            if (y+y_offset+1 < map_y_start) then
                map_y_start = y+y_offset+1 
            elseif (y+y_offset+1 > map_y_end) then
                map_y_end = y+y_offset+1 
            end

            if (x+x_offset+1 < map_x_start) then
                map_x_start = x+x_offset+1 
            elseif (x+x_offset+1 > map_x_end) then
                map_x_end = x+x_offset+1 
            end

            print(map_x_start, map_x_end, map_y_start, map_y_end)

            local_map[y+y_offset+1] = {0}
            -- table.insert(local_map, 0, {0})
            -- local_map[y+y_offset][x+x_offset] = 0

            -- print(local_map)
        end
        -- delta_time = 0
    -- end

    if debug_map then
        for i = map_y_start, map_y_end do -- goes through all the rows 
            for j = map_x_start, map_x_end do -- goes through all the columns in the row
                
                color = {}
                node_type = local_map[i][j]
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

                x_alt = 15*(x+x_offset - (j-1)) 
                y_alt = 15*(y+y_offset - (i-1)) 
                -- print(x, x_offset, i-1, j-1)
                gui.box(123-x_alt, 90-y_alt, 133-x_alt, 100-y_alt, color, {255, 255, 255, 255})

                -- center: gui.box(123, 90, 133, 100, {255, 0, 0, 255}, {255, 255, 255, 255})
            end
        end
    end

    -- gui.box(0, 0, 255, 191, {255, 0, 0, 255}, {255, 255, 255, 255})

    emu.frameadvance()
end
