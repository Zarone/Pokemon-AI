GameReader = {}
GameReader.__index = GameReader

-- function get_name()
--     name = {}
--     for i = 0x2234fb0, 0x2234fbC, 2 do
--         val = memory.readbyte(i)
--         if(val == 255) then break 
--         else
--             table.insert(name, string.format("%c", val))
--         end
--     end
--     return (table.concat(name, ""))
-- end

-- function get_enemy_name()
--     for i = 0x02000000, 0x02FFFFFF do
--         if memory.readbyte(i) == 83 then
--             if memory.readbyte(i+2) == 104 then    
--                 if memory.readbyte(i+4) == 97 then
--                     print(string.format("%x", i), memory.readbyte(i+6))
--                 end
--             end
--         end
--     end
-- name = {}
-- for i = 0x2234fb0, 0x2234fbC, 2 do
--     val = memory.readbyte(i)
--     if(val == 255) then break 
--     else
--         table.insert(name, string.format("%c", val))
--     end
-- end
-- return (table.concat(name, ""))
-- end

function GameReader.new(wild_battle)
    instance = setmetatable({}, GameReader)

    -- instance.name = get_name()
    -- instance.enemy_name = gaaaet_enemy_name()

    instance.last_str = ""
    -- hazards in order: spikes, toxic spikes, stealth rocks, 
    -- reflect, light screen, safeguard, mist, tailwind, lucky chant
    instance.player = {
        hazards = {0, 0, 0, 0, 0, 0, 0, 0, 0},
        volatiles = {}
    }
    instance.enemy = {
        hazards = {0, 0, 0, 0, 0, 0, 0, 0, 0},
        volatiles = {}
    }

    -- instance.nicknames = nicknames
    instance.active = 0
    instance.enemy_active = 0
    instance.wild_battle = wild_battle

    return instance
end

-- function last_substring(str, sep)
--     sep = sep or "[^%s!]+"
--     last = nil
--     for i in string.gmatch(str, sep) do
--         last = i
--     end
--     return(last)
-- end

function GameReader:new_active()
    -- 02271CBE
    -- self.active = memory.readbyte(0x021F44AA)
    -- self.active = memory.readbyte(0x02271CBE)
    -- self.active = memory.readbyte(0x021F44AB)
    if self.wild_battle then
        print('wild')
        self.active = memory.readbyte(0x022724C8)
    else
        print('trainer')
        self.active = memory.readbyte(0x02273226)
    end
end

function GameReader:new_enemy_active()
    self.enemy_active = memory.readbyte(0x02273229) - 12
end

function GameReader:process_line(line)

    player = nil
    hazard_change = false
    hazard = nil -- 1 is spikes, 2 is toxic spikes, 3 is stealth rocks
    new_hazard = nil

    -- Go! \xf000Ă\x0001\x0000!
    -- Go! \xf000Ă\x0001\x0000 and\xfffe\xf000Ă\x0001\x0001!
    -- Go! \xf000Ă\x0001\x0000,\xfffe\xf000Ă\x0001\x0001, and \xf000Ă\x0001\x0002!
    -- You're in charge, \xf000Ă\x0001\x0000!
    -- Go for it, \xf000Ă\x0001\x0000!
    -- Just a little more!\xfffeHang in there, \xf000Ă\x0001\x0000!
    -- Your foe's weak!\xfffeGet 'em, \xf000Ă\x0001\x0000!

    -- \xf000Ď\x0001\x0000 \xf000Ā\x0001\x0001 sent\xfffeout \xf000Ă\x0001\x0002!
    -- \xf000Ď\x0001\x0000 \xf000Ā\x0001\x0001 sent out\xfffe\xf000Ă\x0001\x0002 and \xf000Ă\x0001\x0003!
    -- \xf000Ď\x0001\x0000 \xf000Ā\x0001\x0001 sent out\xfffe\xf000Ă\x0001\x0002, \xf000Ă\x0001\x0003,\xf000븀\x0000\xfffeand \xf000Ă\x0001\x0004!
    -- \xf000Ā\x0001\x0000 sent out\xfffe\xf000Ă\x0001\x0001!
    -- \xf000Ā\x0001\x0000 sent out\xfffe\xf000Ă\x0001\x0001 and \xf000Ă\x0001\x0002!
    -- \xf000Ā\x0001\x0000 sent out\xfffe\xf000Ă\x0001\x0001, \xf000Ă\x0001\x0002,\xf000븀\x0000\xfffeand \xf000Ă\x0001\x0003!

    if line:find("Go!", 0) then
        self:new_active()
        print("switch,", self.active)
        -- print("switch to: ", last_substring(line))
        -- player = 1
    elseif line:find("You're in charge,", 0) then
        self:new_active()
        print("switch,", self.active)
    elseif line:find("Go for it,", 0) then
        self:new_active()
        print("switch,", self.active)
    elseif line:find("Just a little more!", 0) then
        self:new_active()
        print("switch,", self.active)
    elseif line:find("Your foe's weak!", 0) then
        self:new_active()
        print("switch,", self.active)
    elseif line:find("sent out") then
        self:new_enemy_active()
        print("enemy switch", self.enemy_active)
    elseif line == "Spikes were scattered all around your team\'s feet!" then
        hazard_change = true
        hazard = 1
        player = 1
        new_hazard = self.player.hazards[1] + 1
    elseif line == "Spikes were scattered all around the feet of the foe\'s team!" then
        hazard_change = true
        hazard = 1
        player = 2
        new_hazard = self.enemy.hazards[1] + 1
    elseif line == "The spikes disappeared from around your team\'s feet!" then
        hazard_change = true
        hazard = 1
        player = 1
        new_hazard = 0
    elseif line == "The spikes disappeared from around the foe's team\'s feet!" then
        hazard_change = true
        hazard = 1
        player = 2
        new_hazard = 0
    elseif line == "Poison spikes were scattered all around your team\'s feet!" then
        hazard_change = true
        hazard = 2
        player = 1
        new_hazard = self.player.hazards[2] + 1
    elseif line == "Poison spikes were scattered all around the foe\'s team's feet!" then
        hazard_change = true
        hazard = 2
        player = 2
        new_hazard = self.enemy.hazards[2] + 1
    elseif line == "The poison spikes disappeared from around your team\'s feet!" then
        hazard_change = true
        hazard = 2
        player = 1
        new_hazard = 0
    elseif line == "The poison spikes disappeared from around the foe\'s team's feet!" then
        hazard_change = true
        hazard = 2
        player = 2
        new_hazard = 0
    elseif line == "Pointed stones float in the air around your team!" then
        hazard_change = true
        hazard = 3
        player = 1
        new_hazard = 1
    elseif line == "Pointed stones float in the air around your foe\'s team!" then
        hazard_change = true
        hazard = 3
        player = 2
        new_hazard = 1
    elseif line == "The pointed stones disappeared from around your team!" then
        hazard_change = true
        hazard = 3
        player = 1
        new_hazard = 0
    elseif line == "The pointed stones disappeared from around the foe\'s team!" then
        hazard = 3
        hazard_change = true
        player = 2
        new_hazard = 0
    elseif line == "Reflect raised your team\'s Defense!" then
        hazard_change = true
        player = 1
        hazard = 4
        new_hazard = 5
    elseif line == "Reflect raised the opposing team's Defense!" then
        hazard = 4
        player = 2
        hazard_change = true
        new_hazard = 5
    elseif line == "Your team's Reflect wore off!" then
        hazard = 4
        player = 1
        hazard_change = true
        new_hazard = 0
    elseif line == "The opposing team's Reflect wore off!" then
        hazard = 4
        hazard_change = true
        player = 2
        new_hazard = 0
    elseif line == "Light Screen raised your team's Special Defense!" then
        player = 1
        hazard = 5
        new_hazard = 5
        hazard_change = true
    elseif line == "Light Screen raised the opposing team's Special Defense!" then
        hazard = 5
        new_hazard = 5
        player = 2
        hazard_change = true
    elseif line == "Your team's Light Screen wore off!" then
        player = 1
        hazard = 5
        new_hazard = 0
        hazard_change = true
    elseif line == "The opposing team's Light Screen wore off!" then
        hazard = 5
        new_hazard = 0
        player = 2
        hazard_change = true
    elseif line == "Your team became cloaked in a mystical veil!" then
        hazard = 6
        player = 1
        new_hazard = 5
        hazard_change = true
    elseif line == "The foe's team became cloaked in a mystical veil!" then
        player = 2
        hazard = 6
        new_hazard = 5
        hazard_change = true
    elseif line == "Your team is no longer protected by Safeguard!" then
        hazard = 6
        player = 1
        new_hazard = 0
        hazard_change = true
    elseif line == "The foe's team is no longer protected by Safeguard!" then
        hazard = 6
        player = 2
        new_hazard = 0
        hazard_change = true
    elseif line == "Your team became shrouded in mist!" then
        hazard = 7
        player = 1
        hazard_change = true
        new_hazard = 5
    elseif line == "The foe's team became shrouded in mist!" then
        hazard = 7
        hazard_change = true
        new_hazard = 5
        player = 2
    elseif line == "Your team is no longer protected by mist!" then
        hazard = 7
        player = 1
        new_hazard = 0
        hazard_change = true
    elseif line == "The foe's team is no longer protected by mist!" then
        hazard = 7
        player = 2
        new_hazard = 0
        hazard_change = true
    elseif line == "The tailwind blew from behind your team!" then
        hazard = 8
        player = 1
        new_hazard = 4
        hazard_change = true
    elseif line == "The tailwind blew from behind the foe's team!" then
        hazard = 8
        player = 2
        new_hazard = 4
        hazard_change = true
    elseif line == "Your team's tailwind petered out!" then
        hazard = 8
        new_hazard = 0
        player = 1
        hazard_change = true
    elseif line == "The foe's team's tailwind petered out!" then
        hazard = 8
        new_hazard = 0
        player = 2
        hazard_change = true
    elseif line == "The Lucky Chant shielded your team from critical hits!" then
        hazard = 9
        player = 1
        new_hazard = 5
        hazard_change = true
    elseif line == "The Lucky Chant shielded the opposing team from critical hits!" then
        hazard = 9
        player = 2
        new_hazard = 5
        hazard_change = true
    elseif line == "Your team's Lucky Chant wore off!" then
        hazard = 9
        player = 1
        new_hazard = 0
        hazard_change = true
    elseif line == "The opposing team's Lucky Chant wore off!" then
        new_hazard = 0
        hazard = 9
        player = 2
        hazard_change = true
    end

    if hazard_change then
        if player == 1 then
            self.player.hazards[hazard] = new_hazard
        elseif player == 2 then
            self.enemy.hazards[hazard] = new_hazard
        else
            print("somethings wrong with player variable")
        end
    end
end

function GameReader:get_line()
    str = {}
    startChar = 0x02296380
    endChar = startChar + 2 * memory.readbyte(0x0229637A) - 1
    for i = startChar, endChar, 2 do
        byteVal = memory.readbyte(i)
        if byteVal == 254 then
            table.insert(str, " ")
        else
            table.insert(str, string.char(memory.readbyte(i)))
        end
    end
    new_str = table.concat(str, "")
    if self.last_str ~= new_str then
        self:process_line(new_str)
    end
    self.last_str = new_str
end

function GameReader:pass_turn()
    if self.player.hazards[4] > 0 then
        self.player.hazards[4] = self.player.hazards[4] - 1
    end
    if self.enemy.hazards[4] > 0 then
        self.enemy.hazards[4] = self.enemy.hazards[4] - 1
    end
    if self.player.hazards[5] > 0 then
        self.player.hazards[5] = self.player.hazards[5] - 1
    end
    if self.enemy.hazards[5] > 0 then
        self.enemy.hazards[5] = self.enemy.hazards[5] - 1
    end
    if self.player.hazards[6] > 0 then
        self.player.hazards[6] = self.player.hazards[6] - 1
    end
    if self.enemy.hazards[6] > 0 then
        self.enemy.hazards[6] = self.enemy.hazards[6] - 1
    end
    if self.player.hazards[7] > 0 then
        self.player.hazards[7] = self.player.hazards[7] - 1
    end
    if self.enemy.hazards[7] > 0 then
        self.enemy.hazards[7] = self.enemy.hazards[7] - 1
    end
    if self.player.hazards[8] > 0 then
        self.player.hazards[8] = self.player.hazards[8] - 1
    end
    if self.enemy.hazards[8] > 0 then
        self.enemy.hazards[8] = self.enemy.hazards[8] - 1
    end
    if self.player.hazards[9] > 0 then
        self.player.hazards[9] = self.player.hazards[9] - 1
    end
    if self.enemy.hazards[9] > 0 then
        self.enemy.hazards[9] = self.enemy.hazards[9] - 1
    end
    if self.player.hazards[9] > 0 then
        self.player.hazards[9] = self.player.hazards[9] - 1
    end
    if self.enemy.hazards[10] > 0 then
        self.enemy.hazards[10] = self.enemy.hazards[10] - 1
    end
end

return {
    GameReader = GameReader
}
