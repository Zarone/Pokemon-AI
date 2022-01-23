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
    x = 235
    y = 172
    print( {gui.getpixel(x, y)} )
    -- gui.box(x, y, x+5, y+5, {255, 255, 255})
    -- gui.pixel(x, y, {255, 0, 255})
    emu.frameadvance()
end

-- 20, -150
-- 85 -156