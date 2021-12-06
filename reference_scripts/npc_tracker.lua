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
    ows = md(0x02000024) + 0x34E04
    game = 1
else
    ows = md(0x02000024) + 0x36BE8
    game = 2
end

function get_local_info()
    return memory.readword(0x0224F90C), memory.readword(0x0224F912, 2), memory.readword(0x0224F91A),
        memory.readword(0x0224F916)
end

function main()

    mode = 2
    editat = 0x08 + 5 * 0x14 + ows
    count = mb(ows + 3 + mode)

    -- gui.text(1, 50, sf("%d", memory.readword(editat + 227 * 0x24 - 2 + 16 * 14)))
    -- gui.text(1, 60, sf("%d", memory.readword(editat + 227 * 0x24 + 6 + 16 * 14)))
    -- gui.text(1, 70, sf("%d", memory.readword(editat + 227 * 0x24 - 2 + 16 * 30)))
    -- gui.text(1, 80, sf("%d", memory.readword(editat + 227 * 0x24 + 6 + 16 * 30)))
    -- gui.text(1, 90, sf("%d", memory.readword(editat + 227 * 0x24 - 2 + 16 * 46)))
    -- gui.text(1, 100, sf("%d", memory.readword(editat + 227 * 0x24 + 6 + 16 * 46)))
    -- gui.text(1, 110, sf("%d", memory.readword(editat + 227 * 0x24 - 2 + 16 * 62)))
    -- gui.text(1, 120, sf("%d", memory.readword(editat + 227 * 0x24 + 6 + 16 * 62)))
    -- gui.text(1, 130, sf("%d", memory.readword(editat + 227 * 0x24 - 2 + 16 * 78)))
    -- gui.text(1, 140, sf("%d", memory.readword(editat + 227 * 0x24 + 6 + 16 * 78)))
    -- gui.text(1, 150, sf("%d", memory.readword(editat + 227 * 0x24 - 2 + 16 * 94)))
    -- gui.text(1, 160, sf("%d", memory.readword(editat + 227 * 0x24 + 6 + 16 * 94)))

    for i = 0, count-1
    do
        gui.text(1, i*20+60, sf("%d", memory.readword(editat + 227 * 0x24 - 2 + 16 * (14+16*i))))
        gui.text(1, i*20+70, sf("%d", memory.readword(editat + 227 * 0x24 + 6 + 16 * (14+16*i))))
    end

    -- Debug
    gt(1, 10, sf("OW Data Start: %08X", ows))
    gt(1, 20, sf("Desired Count: %d", count))
    gt(1, 30, sf("editat: %08X", editat))
    gt(1, 40, sf("mb(0x04 + ows): %s", mb(0x04 + ows)))

end
gui.register(main)
