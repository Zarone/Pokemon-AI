local rshift, lshift = bit.rshift, bit.lshift
local wd, ww, wb = memory.writedword, memory.writeword, memory.writebyte
local rd, rw, rb = memory.readdwordunsigned, memory.readwordunsigned, memory.readbyteunsigned
mb = function(x)
    return rb(x)
end
mw = function(x)
    return rb(x) + rb(x + 1) * 0x100
end
md = function(x)
    return rb(x) + rb(x + 1) * 0x100 + rb(x + 2) * 0x10000 + rb(x + 3) * 0x1000000
end
local gt, sf = gui.text, string.format

if mb(0x023FFE09) == 0x00 then -- Not "2" ~ Not B2/W2
    pos_m = md(0x02000024) + 0x3461C
    zds = md(0x02000024) + 0x3DFAC
    ows = md(0x02000024) + 0x34E04
    game = 1
else
    pos_m = md(0x02000024) + 0x36780
    zds = md(0x02000024) + 0x41B2C
    ows = md(0x02000024) + 0x36BE8
    game = 2
end

local useupper = true
local L8 = 0x01
local U8 = 0x00
local edit = "NPC"

local mapexit = 1
local offset = 0x02 -- sprite. change to 0xA for script reassigning

function get_local_info()
    return memory.readword(0x0224F90C), memory.readword(0x0224F912, 2), memory.readword(0x0224F91A),
        memory.readword(0x0224F916)
end

function main()
    -- L8=math.random(500)
    -- mapexit=math.random(6)

    if edit == "Furniture" then
        mode = 1
        mult = 0x14
        editat = 0x08 + ows
    elseif edit == "NPC" then
        mode = 2
        mult = 0x24
        editat_test = 0x08 + 5 * 0x14 + ows
        editat = 0x08 + mb(0x04 + ows) * 0x14 + ows
    elseif edit == "Warp" then
        mode = 3
        mult = 0x14
        editat = 0x08 + mb(0x04 + ows) * 0x14 + mb(0x05 + ows) * 0x24 + ows
    elseif edit == "Trigger" then
        mode = 4
        mult = 0x16
        editat = 0x08 + mb(0x04 + ows) * 0x14 + mb(0x05 + ows) * 0x24 + mb(0x06 + ows) * 0x14 + ows
    end
    count = mb(ows + 3 + mode)

    print(sf("first check at: %x", editat + 227 * 0x24 - 2 + 16 * 14))
    gui.text(1, 50, sf("%d", memory.readword(editat_test + 227 * 0x24 - 2 + 16 * 14)))
    gui.text(1, 60, sf("%d", memory.readword(editat_test + 227 * 0x24 + 6 + 16 * 14)))
    gui.text(1, 70, sf("%d", memory.readword(editat_test + 227 * 0x24 - 2 + 16 * 30)))
    gui.text(1, 80, sf("%d", memory.readword(editat_test + 227 * 0x24 + 6 + 16 * 30)))
    gui.text(1, 90, sf("%d", memory.readword(editat_test + 227 * 0x24 - 2 + 16 * 46)))
    gui.text(1, 100, sf("%d", memory.readword(editat_test + 227 * 0x24 + 6 + 16 * 46)))
    gui.text(1, 110, sf("%d", memory.readword(editat_test + 227 * 0x24 - 2 + 16 * 62)))
    gui.text(1, 120, sf("%d", memory.readword(editat_test + 227 * 0x24 + 6 + 16 * 62)))
    gui.text(1, 130, sf("%d", memory.readword(editat_test + 227 * 0x24 - 2 + 16 * 78)))
    gui.text(1, 140, sf("%d", memory.readword(editat_test + 227 * 0x24 + 6 + 16 * 78)))
    gui.text(1, 150, sf("%d", memory.readword(editat_test + 227 * 0x24 - 2 + 16 * 94)))
    gui.text(1, 160, sf("%d", memory.readword(editat_test + 227 * 0x24 + 6 + 16 * 94)))
    -- print(sf("%x", editat+ offset + 3*mult))
    -- print(sf("%x", editat+ offset + 4*mult))

    -- word editing mode
    if useupper == true then
        if mw(editat + offset) ~= (L8 + U8 * 0x100) then
            i = 0
            gt(1, 00, sf("Map is Switching!"))
            while i < count do
                insert = (L8 + U8 * 0x100)
                if mode == 3 then
                    ww(i * mult + offset + editat + 4, mapexit)
                end
                ww(i * mult + offset + editat, insert)
                i = i + 1
            end
        end
    end

    -- byte editing mode
    if useupper == false then
        if mb(editat + offset) ~= (L8) then
            i = 0
            gt(1, 00, sf("Map is Switching!"))
            while i < count do
                insert = (L8)
                if mode == 3 then
                    ww(i * mult + offset + editat + 4, mapexit)
                end
                wb(i * mult + offset + editat, insert)
                i = i + 1
            end
        end
    end

    -- Debug
    gt(1, 10, sf("OW Data Start: %08X", ows))
    gt(1, 20, sf("Desired Count: %d", count))
    gt(1, 30, sf("editat: %08X", editat))
    gt(1, 40, sf("mb(0x04 + ows): %s", mb(0x04 + ows)))

end
gui.register(main)
