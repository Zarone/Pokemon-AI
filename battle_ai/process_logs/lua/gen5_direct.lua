GameReader = {}
GameReader.__index = GameReader

function GameReader.new()
    instance = setmetatable({}, GameReader)

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

    return instance
end

function GameReader:process_line(line)

    hazard_change = false
    player = nil
    hazard = nil -- 1 is spikes, 2 is toxic spikes, 3 is stealth rocks
    new_hazard = nil

    if line == "Spikes were scattered all around your team\'s feet!" then
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

function GameReader:read()
    self:process_line(self:get_line())
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
