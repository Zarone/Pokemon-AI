-- x = 0
-- y = 0

-- for i = 0, 257, 20 do
--     for j = -192, 192, 20 do
--         print(i, j)
--         gui.box(i, j, i+10, j+10, {255, 0, 255})
--         gui.pixel(i, j, {255, 0, 0})
--         emu.frameadvance()
--     end
-- end

while true do

    -- 20 -150 => { 255, 255, 255 }    
    r1, g1, b1 = gui.getpixel(20, -150)

    -- okay so a weird potential source of bugs in the future,
    -- I'm like 40% sure that this g value, the second color
    -- value in get pixel is occasionally 173. I'm not sure
    -- so I didn't want to add a condition here, but I feel 
    -- like I want to make a reminder here.

    -- 85 -156 => { 255, 174, ? }
    r2, g2 = gui.getpixel(85, -156)

    -- 127, 10 => {115, 0, 24}
    r3, g3, b3 = gui.getpixel(127, 10)
    -- 120, 155 => {123, 123, 132}
    r4, g4 = gui.getpixel(120, 155)

    local is_in_battle = (r1 == 255 and g1 == 255 and b1 == 255 and r2 == 255 and g2 == 174) or (r3 == 115 and g3 == 0 and b3 == 24 and r4 == 123 and g4 == 123)
    print(is_in_battle)

    x = 120
    y = 155
    -- print( {gui.getpixel(x, y)} )
    -- gui.box(x, y, x+15, y+15, {255, 255, 255})
    -- gui.pixel(x, y, {0, 0, 255})

    emu.frameadvance()
end

-- 120, 80 => {57, 8, 16}
-- 120, 125 => {66, 66, 66}