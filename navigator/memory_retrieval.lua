local mem = {}
local ows
local game
local mode = 2

local rb = memory.readbyteunsigned

function mem.md(x)
    return rb(x) + rb(x + 1) * 0x100 + rb(x + 2) * 0x10000 + rb(x + 3) * 0x1000000
end

if memory.readbyteunsigned(0x023FFE09) == 0x00 then -- Not "2" ~ Not B2/W2
    ows = mem.md(0x02000024) + 0x34E04
    game = 1
else
    ows = mem.md(0x02000024) + 0x36BE8
    game = 2
end

function mem.get_map()
    return memory.readword(0x0224F90C)
end

function mem.get_pos()
    return memory.readword(0x0224F912, 2), memory.readword(0x0224F91A), memory.readword(0x0224F916)
end

function mem.get_npc_mem()
    editat = 0x08 + 5 * 0x14 + ows
    count = memory.readbyteunsigned(ows + 3 + mode)
    return editat, count

end

function mem.is_dialogue_onscreen()
    -- maybe: 0x0224F77D
    -- maybe: 0x022842A9
    -- maybe: 0x022842A9

    -- maybe means can't move: 0x0224F77D

    -- maybe: 0x0225C5DF
    return memory.readbyteunsigned(0x0225C5DF) == 2
end

function mem.is_in_battle()
    -- 20, -150 => { 255, 255, 255 }
    r1, g1, b1 = gui.getpixel(20, -150)


    -- okay so a weird potential source of bugs in the future,
    -- I'm like 40% sure that this g value, the second color
    -- value in get pixel is occasionally 173. I'm not sure
    -- so I didn't want to add a condition here, but I feel 
    -- like I want to make a reminder here.

    -- 85 -156 => { 255, 174, ? }
    r2, g2 = gui.getpixel(85, -156)
    -- 120, 80 => {57, 8, 16}
    r3, g3, b3 = gui.getpixel(120, 80)
    -- 120, 125 => {66, 66, 66}
    r4, g4 = gui.getpixel(120, 125)

    local is_in_battle = (r1 == 255 and g1 == 255 and b1 == 255 and r2 == 255 and g2 == 174) or (r3 == 57 and g3 == 8 and b3 == 16 and r4 == 66 and g4 == 66)
    return is_in_battle
    -- return memory.readbyteunsigned(0x022D5C0B) ~= 0
    -- return memory.readbyteunsigned(0x02122DE6)    
end

function mem.can_move()
    return memory.readbyteunsigned(0x0224F77D)
end

return mem