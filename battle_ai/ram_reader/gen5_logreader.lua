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

function GameReader.new(wild_battle, nicknames, nicknames_enemy)
    instance = setmetatable({}, GameReader)

    -- instance.name = get_name()
    -- instance.enemy_name = gaaaet_enemy_name()

    instance.last_str = ""
    -- hazards in order: spikes, toxic spikes, stealth rocks, 
    -- reflect, light screen, safeguard, mist, tailwind, lucky chant
    instance.player = {
        hazards = {0, 0, 0, 0, 0, 0, 0, 0, 0},
        volatiles = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
        -- # Seeded
        -- # Confused
        -- # Taunted
        -- # Yawning
        -- # Perish Song (0 for none, 1 for 3 turns left, 2 for 2 turns left, 3 for 1 turn left)

        -- # Substitute
        -- # Focus Energy
        -- # Ingrain
        -- # disable (0 for none, or 1,2,3,4 for disabled move)
        -- # encore

        -- # futuresight
        -- # aquaring
        -- # attract
        -- # torment
    }
    instance.enemy = {
        hazards = {0, 0, 0, 0, 0, 0, 0, 0, 0},
        volatiles = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    }

    instance.nicknames = nicknames
    instance.nicknames_enemy = nicknames_enemy
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
        self.active = memory.readbyte(0x022724C8)
    else
        self.active = memory.readbyte(0x02273226)
    end
    self.player.volatiles = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, self.player.volatiles[11], 0, 0, 0}
    -- # Seeded
    -- # Confused
    -- # Taunted
    -- # Yawning
    -- # Perish Song (0 for none, 1 for 3 turns left, 2 for 2 turns left, 3 for 1 turn left)

    -- # Substitute
    -- # Focus Energy
    -- # Ingrain
    -- # disable (0 for none, or 1,2,3,4 for disabled move)
    -- # encore

    -- # futuresight
    -- # aquaring
    -- # attract
    -- # torment
end

function GameReader:new_enemy_active()
    self.enemy_active = memory.readbyte(0x02273229) - 12
    self.enemy.volatiles = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, self.enemy.volatiles[11], 0, 0, 0}
end

function GameReader:process_line(line)

    player = nil
    hazard_change = false
    hazard = nil -- 1 is spikes, 2 is toxic spikes, 3 is stealth rocks
    new_hazard = nil

    if line:find("Go!", 0) then
        self:new_active()
    elseif line:find("You're in charge,", 0) then
        self:new_active()
        print("switch,", self.active)
    elseif line:find("Go for it,", 0) then
        self:new_active()
        print("switch,", self.active)
    elseif line:find("Just a little more!", 0) then
        self:new_active()
    elseif line:find("Your foe's weak!", 0) then
        self:new_active()
    elseif line:find("sent out") then
        self:new_enemy_active()
    elseif line == self.nicknames[self.active + 1] .. " was seeded!" then
        self.player.volatiles[1] = 1
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. " was seeded!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. " was seeded!") then
        self.enemy.volatiles[1] = 1
    elseif line == self.nicknames[self.active + 1] .. " became confused!" or line == self.nicknames[self.active + 1] ..
        " became confused due to fatigue!" then
        self.player.volatiles[2] = 1
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
        " became confused!" or line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
        " became confused due to fatique!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] ..
            " became confused!" or line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] ..
            " became confused due to fatigue!") then
        self.enemy.volatiles[2] = 1
    elseif line == self.nicknames[self.active + 1] .. " snapped out of its confusion." then
        self.player.volatiles[2] = 0
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
        " snapped out of confusion!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] ..
            " snapped out of confusion!") then
        self.enemy.volatiles[2] = 0
    elseif line == self.nicknames[self.active + 1] .. " fell for the taunt!" then
        self.player.volatiles[3] = 1
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
        " fell for the taunt!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] ..
            " fell for the taunt!") then
        self.enemy.volatiles[3] = 1
    elseif line == self.nicknames[self.active + 1] .. " grew drowsy!" then
        self.player.volatiles[4] = 1
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. " grew drowsy!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. " grew drowsy!") then
        self.enemy.volatiles[4] = 1
    elseif line.find(self.nicknames[self.active + 1] .. "'s perish count", 0) then
        self.player.volatiles[5] = 4 - tonumber(line:sub(-2, -2))
    elseif line.find(self.wild_battle and "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
                         "'s perish count" or "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] ..
                         "'s perish count") then
        self.enemy.volatiles[5] = 4 - tonumber(line:sub(-2, -2))
    elseif line == self.nicknames[self.active + 1] .. " put in a substitute!" then
        self.player.volatiles[6] = 1
    elseif line ==
        (self.wild_battle and "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. " put in a substitute!" or
            "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. " put in a substitute!") then
        self.enemy.volatiles[6] = 1
    elseif line == self.nicknames[self.active + 1] .. "'s substitute faded!" then
        self.player.volatiles[6] = 0
    elseif line ==
        (self.wild_battle and "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. "'s substitute faded!" or
            "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. "'s substitute faded!") then
        self.enemy.volatiles[6] = 0
    elseif line == self.nicknames[self.active + 1] .. " is tightening its focus!" then
        self.player.volatiles[7] = 1
    elseif line ==
        (self.wild_battle and "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. " is tightening its focus!" or
            "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. " is tightening its focus!") then
        self.enemy.volatiles[7] = 1
    elseif line == self.nicknames[self.active + 1] .. " planted its roots!" then
        self.player.volatiles[8] = 1
    elseif line ==
        (self.wild_battle and "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. " planted its roots!" or
            "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. " planted its roots!") then
        self.enemy.volatiles[8] = 1

        -- \xf000Ă\x0001\x0000's \xf000ć\x0001\x0001\xfffewas disabled!
        -- The wild \xf000Ă\x0001\x0000's\xfffe\xf000ć\x0001\x0001 was disabled!
        -- The foe's \xf000Ă\x0001\x0000's\xfffe\xf000ć\x0001\x0001 was disabled!
        -- \xf000Ă\x0001\x0000's \xf000ć\x0001\x0001\xfffeis disabled!
        -- The wild \xf000Ă\x0001\x0000's\xfffe\xf000ć\x0001\x0001 is disabled!
        -- The foe's \xf000Ă\x0001\x0000's\xfffe\xf000ć\x0001\x0001 is disabled!
        -- \xf000Ă\x0001\x0000 is no\xfffelonger disabled!
        -- The wild \xf000Ă\x0001\x0000 is no\xfffelonger disabled!
        -- The foe's \xf000Ă\x0001\x0000 is no\xfffelonger disabled!

        -- \xf000Ă\x0001\x0000 received\xfffean encore!
        -- The wild \xf000Ă\x0001\x0000 received\xfffean encore!
        -- The foe's \xf000Ă\x0001\x0000 received\xfffean encore!
        -- \xf000Ă\x0001\x0000's encore\xfffeended!
        -- The wild \xf000Ă\x0001\x0000's encore\xfffeended!
        -- The foe's \xf000Ă\x0001\x0000's encore\xfffeended!

        -- \xf000Ă\x0001\x0000 foresaw\xfffean attack!
        -- The wild \xf000Ă\x0001\x0000 foresaw\xfffean attack!
        -- The foe's \xf000Ă\x0001\x0000 foresaw\xfffean attack!

        --     \xf000Ă\x0001\x0000 surrounded\xfffeitself with a veil of water!
        -- The wild \xf000Ă\x0001\x0000 surrounded\xfffeitself with a veil of water!
        -- The foe's \xf000Ă\x0001\x0000 surrounded\xfffeitself with a veil of water!

        -- \xf000Ă\x0001\x0000\xfffefell in love!
        -- The wild \xf000Ă\x0001\x0000\xfffefell in love!
        -- The foe's \xf000Ă\x0001\x0000\xfffefell in love!
        -- \xf000Ă\x0001\x0000\xfffefell in love from the \xf000ĉ\x0001\x0001!
        -- The wild \xf000Ă\x0001\x0000\xfffefell in love from the \xf000ĉ\x0001\x0001!
        -- The foe's \xf000Ă\x0001\x0000\xfffefell in love from the \xf000ĉ\x0001\x0001!
        -- \xf000Ă\x0001\x0000 is in love\xfffewith \xf000Ă\x0001\x0001!
        -- The wild \xf000Ă\x0001\x0000 is in love\xfffewith \xf000Ă\x0001\x0001!
        -- The foe's \xf000Ă\x0001\x0000 is in love\xfffewith \xf000Ă\x0001\x0001!
        -- \xf000Ă\x0001\x0000 got over its\xfffeinfatuation.
        -- The wild \xf000Ă\x0001\x0000 got over its\xfffeinfatuation.
        -- The foe's \xf000Ă\x0001\x0000 got over its\xfffeinfatuation.

        -- \xf000Ă\x0001\x0000\xfffeis tormented!
        -- The wild \xf000Ă\x0001\x0000\xfffeis tormented!
        -- The foe's \xf000Ă\x0001\x0000\xfffeis tormented!
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
