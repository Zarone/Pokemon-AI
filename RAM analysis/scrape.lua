JSON = require("lunajson")
selectPressed = false
startPressed = false
saved = 117

startRam = 0x021F3CB4
endRam = 0x021F456F
-- endRam = 0x021F45D4

default_args = { {0, 0, 0, 1}, {0, 0, 1}, {0, 1} } -- spikes, toxic spikes, stealth rocks

function scrapeBytes(rangeStart, rangeEnd)
    bytes = {}
    for i = rangeStart, rangeEnd, 1 do
        bytes[#bytes+1] = memory.readbyte(i)
    end
    
    file = io.open("./states/"..saved..".json", "w")
    file:write(JSON.encode({ default_args, bytes })) 
    file:close()
    saved = saved + 1
end

function scrapeWords(rangeStart, rangeEnd)
    words = {}
    for i = rangeStart, rangeEnd, 4 do
        words[#words+1] = memory.readword(i)
    end
    
    file = io.open("./states/"..saved..".json", "w")
    file:write(JSON.encode({ default_args, words })) 
    file:close()
    saved = saved + 1
end

function scrapeWordsToPrediction(rangeStart, rangeEnd)
    words = {}
    for i = rangeStart, rangeEnd, 4 do
        words[#words+1] = memory.readword(i)
    end
    
    file = io.open("./predict.json", "w")
    file:write(JSON.encode({ default_args, words })) 
    file:close()
end

function loop()

    if(joypad.get(1).select and not selectPressed) then -- mapped to v
        selectPressed = true
        scrapeWords(startRam, endRam)
    elseif (not joypad.get(1).select and selectPressed) then
        selectPressed = false
    end 

    if(joypad.get(1).start and not startPressed) then -- mapped to c
        startPressed = true
        scrapeWordsToPrediction(startRam, endRam)
    elseif (not joypad.get(1).start and startPressed) then
        startPressed = false
    end 

end

gui.register(loop)
