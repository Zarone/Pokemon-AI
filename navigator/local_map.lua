local x = nil
local y = nil
-- local z = nil
local map_id = nil

local delta_time = 0
local wait_frames = 24

-- 0 is players location
-- 1 is movable space
-- 2 is unmovable space
-- 3 is warp space
local local_map = {
    {0}
}

function get_local_info()
    return memory.readword(0x0224F90C), memory.readword(0x0224F912, 2), memory.readword(0x0224F91A),
        memory.readword(0x0224F916)
end

while true do
    delta_time = delta_time + 1

    if delta_time % wait_frames == 0 then

        map_id, x, y = get_local_info()
        print(map_id, x, y)
        delta_time = 0

    end
    emu.frameadvance()
end

-- 788 745