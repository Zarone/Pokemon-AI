GameReader = {}
GameReader.__index = GameReader

function GameReader.new()
    instance = setmetatable({}, GameReader)
    
    instance.last_str = ""
    
    return instance
end

function GameReader:read()
    str = {}
    startChar = 0x02296380
    endChar = startChar+2*memory.readbyte(0x0229637A)-1
    for i = startChar, endChar , 2 do
        byteVal = memory.readbyte(i)
        if byteVal == 254 then
            table.insert(str, " ")
        else
            table.insert(str, string.char(memory.readbyte(i)))
        end
    end
    new_str = table.concat(str, "")
    if self.last_str ~= new_str then
        print(new_str)
    end
    self.last_str = new_str
end

return {GameReader=GameReader}