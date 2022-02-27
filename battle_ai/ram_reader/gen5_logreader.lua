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

function move_to_id(move)
    return move:gsub(" ", ""):gsub("-", ""):lower()
end

function GameReader.new(wild_battle, nicknames, nicknames_enemy)
    instance = setmetatable({}, GameReader)

    instance.last_str = ""
    -- hazards in order: spikes, toxic spikes, stealth rocks, 
    -- reflect, light screen, safeguard, mist, tailwind, lucky chant
    instance.player = {
        hazards = {0, 0, 0, 0, 0, 0, 0, 0, 0},
        volatiles = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        disabled_move = "",
        last_move = "",
        encored_move = ""
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
        volatiles = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        disabled_move = "",
        last_move = "",
        encored_move = ""
    }

    instance.nicknames = nicknames
    instance.nicknames_enemy = nicknames_enemy
    instance.active = 0
    instance.enemy_active = 0
    instance.wild_battle = wild_battle
    instance.pokemon_order= {0, 1, 2, 3, 4, 5}

    return instance
end

function GameReader:new_active(name_active)
    print(name_active, ": name")
    -- 02271CBE
    -- self.active = memory.readbyte(0x021F44AA)
    -- self.active = memory.readbyte(0x02271CBE)
    -- self.active = memory.readbyte(0x021F44AB)

    if self.wild_battle then
        self.active = memory.readbyte(0x022724C8)
    else
        self.active = memory.readbyte(0x02273226)
    end

    -- if the active immedietely faints
    -- check against nicknames
    if self.active == 31 then
        for i = 1, 6 do
            if name_active == self.nicknames[i] then
                self.active = i-1
            end
        end
    end

    print("new active: ", self.active)
    local temp = self.pokemon_order[1]

    local active_pokemon_slot = nil
    for i = 1, 6 do
        if self.active == self.pokemon_order[i] then
            active_pokemon_slot = i
            break
        end
    end

    -- print("from: ", self.pokemon_order)
    self.pokemon_order[1] = self.pokemon_order[active_pokemon_slot]
    self.pokemon_order[active_pokemon_slot] = temp
    -- print(self.pokemon_order)
    -- print("to: ", self.pokemon_order)
    self.player.disabled_move = ""
    self.player.last_move = ""
    self.player.volatiles = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, self.player.volatiles[11], 0, 0, 0}
    -- # Seeded
    -- # Confused
    -- # Taunted
    -- # Yawning
    -- # Perish Song (0 for none, 1 for 3 turns left, 2 for 2 turns left, 3 for 1 turn left)

    -- # Substitute
    -- # Focus Energy
    -- # Ingrain
    -- # disable
    -- # encore

    -- # futuresight
    -- # aquaring
    -- # attract
    -- # torment
end

function GameReader:new_enemy_active()
    self.enemy_active = memory.readbyte(0x02273229) - 12
    -- print("new enemy active: ", self.enemy_active)
    self.enemy.disabled_move = ""
    self.enemy.last_move = ""
    self.enemy.volatiles = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, self.enemy.volatiles[11], 0, 0, 0}
end

function GameReader:process_line(line)

    player = nil
    hazard_change = false
    hazard = nil -- 1 is spikes, 2 is toxic spikes, 3 is stealth rocks
    new_hazard = nil
    if line:find("Go!", 0) then
        self:new_active(line:sub(5, -2))
        print("new active on line: ", line)
    elseif line:find("You're in charge,", 0) then
        self:new_active(line:sub(19, -2))
        print("new active on line: ", line)
    elseif line:find("Go for it,", 0) then
        self:new_active(line:sub(12, -2))
        print("new active on line: ", line)
    elseif line:find("Just a little more!", 0) then
        self:new_active(line:sub(36, -2))
        print("new active on line: ", line)
    elseif line:find("Your foe's weak!", 0) then
        self:new_active(line:sub(27, -2))
        print("new active on line: ", line)
    elseif line:find("sent out", 0) then
        self:new_enemy_active()
    elseif line:sub(0, #self.nicknames[self.active + 1] + 5) == self.nicknames[self.active + 1] .. " used" then
        self.player.last_move = move_to_id(line:sub(#self.nicknames[self.active + 1] + 7, -2))
    elseif line:sub(0, #self.nicknames_enemy[self.enemy_active + 1] + 14) == "The wild "..self.nicknames_enemy[self.enemy_active + 1].." used" then
        self.enemy.last_move = move_to_id(line:sub(#self.nicknames_enemy[self.enemy_active + 1] + 16, -2))
    elseif line:sub(0, #self.nicknames_enemy[self.enemy_active + 1] + 15) == "The foe's "..self.nicknames_enemy[self.enemy_active + 1].." used" then
        self.enemy.last_move = move_to_id(line:sub(#self.nicknames_enemy[self.enemy_active + 1] + 17, -2))
    elseif line == self.nicknames[self.active + 1] .. " was seeded!" then
        self.player.volatiles[1] = 1
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. " was seeded!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. " was seeded!") then
        self.enemy.volatiles[1] = 1
    elseif line == self.nicknames[self.active + 1] .. " became confused!" or line == self.nicknames[self.active + 1] ..
        " became confused due to fatigue!" then
        self.player.volatiles[2] = 5
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
        " became confused!" or line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
        " became confused due to fatique!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] ..
            " became confused!" or line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] ..
            " became confused due to fatigue!") then
        self.enemy.volatiles[2] = 5
    elseif line == self.nicknames[self.active + 1] .. " snapped out of its confusion." then
        self.player.volatiles[2] = 0
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
        " snapped out of confusion!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] ..
            " snapped out of confusion!") then
        self.enemy.volatiles[2] = 0
    elseif line == self.nicknames[self.active + 1] .. " fell for the taunt!" then
        self.player.volatiles[3] = 3
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
        " fell for the taunt!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] ..
            " fell for the taunt!") then
        self.enemy.volatiles[3] = 3
    elseif line == self.nicknames[self.active + 1] .. "'s taunt wore off!" then
        self.player.volatiles[3] = 0
    elseif line ==
        (self.wild_battle and "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. "'s taunt wore off!" or
            "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. "'s taunt wore off!") then
        self.enemy.volatiles[3] = 0
    elseif line == self.nicknames[self.active + 1] .. " grew drowsy!" then
        self.player.volatiles[4] = 1
    elseif (self.wild_battle and line == "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. " grew drowsy!") or
        (not self.wild_battle and line == "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. " grew drowsy!") then
        self.enemy.volatiles[4] = 1
    elseif line:find(self.nicknames[self.active + 1] .. "'s perish count", 0) then
        self.player.volatiles[5] = 4 - tonumber(line:sub(-2, -2))
    elseif line:find(self.wild_battle and "The wild " .. self.nicknames_enemy[self.enemy_active + 1] ..
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
    elseif line:sub(-13, -2) == "was disabled" then
        if line:sub(0, 8) == "The wild" then
            self.enemy.disabled_move = move_to_id(line:sub(13+#(self.nicknames_enemy[self.enemy_active+1]), -15))
            self.enemy.volatiles[9] = 4
        elseif line:sub(0, 9) == "The foe's" then
            self.enemy.disabled_move = move_to_id(line:sub(14+#(self.nicknames_enemy[self.enemy_active+1]), -15))
            self.enemy.volatiles[9] = 4
        else 
            self.player.disabled_move = move_to_id(line:sub(4+#(self.nicknames[self.active+1]), -15))
            self.player.volatiles[9] = 4
        end
    elseif line:sub(-13, -2) == "ger disabled" then
        if line:sub(0, 8) == "The wild" then
            self.enemy.disabled_move = ""
            self.enemy.volatiles[9] = 0
        elseif line:sub(0, 9) == "The foe's" then
            self.enemy.disabled_move = ""
            self.enemy.volatiles[9] = 0
        else 
            self.player.disabled_move = ""
            self.player.volatiles[9] = 0
        end
    elseif line == self.nicknames[self.active + 1] .. " received an encore!" then
        self.player.volatiles[10] = 3
        self.player.encored_move = self.player.last_move
    elseif line ==
        (self.wild_battle and "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. " received an encore!" or
            "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. " received an encore!") then
        self.enemy.volatiles[10] = 3
        self.enemy.encored_move = self.enemy.last_move
    elseif line == self.nicknames[self.active + 1] .. "'s encore ended!" then
        self.player.volatiles[10] = 0
    elseif line ==
        (self.wild_battle and "The wild " .. self.nicknames_enemy[self.enemy_active + 1] .. "'s encore ended!" or
            "The foe's " .. self.nicknames_enemy[self.enemy_active + 1] .. "'s encore ended!") then
        self.enemy.volatiles[10] = 0
    elseif line:sub(-12, -2) == "w an attack" then
        if line:sub(0, 8) == "The wild" then
            self.player.volatiles[11] = 3
        elseif line:sub(0, 9) == "The foe's" then
            self.player.volatiles[11] = 3
        else 
            self.enemy.volatiles[11] = 3
        end
    elseif line:sub(-15, -2) == "e Sight attack" then
        if line:sub(0, 8) == "The wild" then
            self.enemy.volatiles[11] = 0
        elseif line:sub(0, 9) == "The foe's" then
            self.enemy.volatiles[11] = 0
        else 
            self.player.volatiles[11] = 0
        end
    elseif line:sub(-12, -2) == "il of water" then
        if line:sub(0, 8) == "The wild" or line:sub(0, 9) == "The foe's" then
            self.enemy.volatiles[12] = 1
        else 
            self.player.volatiles[12] = 1
        end
    elseif line:sub(-10, -2) == "l in love" then
        if line:sub(0, 8) == "The wild" or line:sub(0, 9) == "The foe's" then
            self.enemy.volatiles[13] = 1
        else 
            self.player.volatiles[13] = 1
        end
    elseif line:sub(-14, -2) == "s infatuation" then
        if line:sub(0, 8) == "The wild" or line:sub(0, 9) == "The foe's" then
            self.enemy.volatiles[13] = 0
        else 
            self.player.volatiles[13] = 0
        end
    elseif line:sub(-13, -2) == "is tormented" then
        if line:sub(0, 8) == "The wild" or line:sub(0, 9) == "The foe's" then
            self.enemy.volatiles[14] = 1
        else 
            self.player.volatiles[14] = 1
        end
    elseif line:sub(-13, -2) == "ent wore off" then
        if line:sub(0, 8) == "The wild" or line:sub(0, 9) == "The foe's" then
            self.enemy.volatiles[14] = 0
        else 
            self.player.volatiles[14] = 0
        end
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
        hazard_change = true
        new_hazard = 5
    elseif line == "Light Screen raised the opposing team's Special Defense!" then
        hazard = 5
        player = 2
        hazard_change = true
        new_hazard = 5
    elseif line == "Your team's Light Screen wore off!" then
        player = 1
        hazard = 5
        hazard_change = true
        new_hazard = 0
    elseif line == "The opposing team's Light Screen wore off!" then
        hazard = 5
        player = 2
        hazard_change = true
        new_hazard = 0
    elseif line == "Your team became cloaked in a mystical veil!" then
        hazard = 6
        player = 1
        hazard_change = true
        new_hazard = 5
    elseif line == "The foe's team became cloaked in a mystical veil!" then
        player = 2
        hazard = 6
        hazard_change = true
        new_hazard = 5
    elseif line == "Your team is no longer protected by Safeguard!" then
        hazard = 6
        player = 1
        hazard_change = true
        new_hazard = 0
    elseif line == "The foe's team is no longer protected by Safeguard!" then
        hazard = 6
        player = 2
        hazard_change = true
        new_hazard = 0
    elseif line == "Your team became shrouded in mist!" then
        hazard = 7
        player = 1
        hazard_change = true
        new_hazard = 5
    elseif line == "The foe's team became shrouded in mist!" then
        hazard = 7
        hazard_change = true
        player = 2
        new_hazard = 5
    elseif line == "Your team is no longer protected by mist!" then
        hazard = 7
        player = 1
        hazard_change = true
        new_hazard = 0
    elseif line == "The foe's team is no longer protected by mist!" then
        hazard = 7
        player = 2
        hazard_change = true
        new_hazard = 0
    elseif line == "The tailwind blew from behind your team!" then
        hazard = 8
        player = 1
        hazard_change = true
        new_hazard = 4
    elseif line == "The tailwind blew from behind the foe's team!" then
        hazard = 8
        player = 2
        hazard_change = true
        new_hazard = 4
    elseif line == "Your team's tailwind petered out!" then
        hazard = 8
        player = 1
        hazard_change = true
        new_hazard = 0
    elseif line == "The foe's team's tailwind petered out!" then
        hazard = 8
        player = 2
        hazard_change = true
        new_hazard = 0
    elseif line == "The Lucky Chant shielded your team from critical hits!" then
        hazard = 9
        player = 1
        hazard_change = true
        new_hazard = 5
    elseif line == "The Lucky Chant shielded the opposing team from critical hits!" then
        hazard = 9
        player = 2
        hazard_change = true
        new_hazard = 5
    elseif line == "Your team's Lucky Chant wore off!" then
        hazard = 9
        player = 1
        hazard_change = true
        new_hazard = 0
    elseif line == "The opposing team's Lucky Chant wore off!" then
        hazard = 9
        player = 2
        hazard_change = true
        new_hazard = 0
    end

    if hazard_change then
        if player == 1 then
            self.player.hazards[hazard] = new_hazard
        elseif player == 2 then
            self.enemy.hazards[hazard] = new_hazard
            print("enemy hazards set", self.enemy.hazards)
        else
            print("somethings wrong with player variable")
        end
    end
    return false
end

function GameReader:get_line()
    
    new_str = self.line_text()

    returnVal = false

    if new_str:sub(0, 6) == "What w" then
        self.last_str = new_str
        return true
    end

    if self.last_str ~= new_str then
        returnVal = self:process_line(new_str)
    end
    self.last_str = new_str

    return returnVal
end

function GameReader:line_text()
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
    return table.concat(str, "")
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
    if self.player.volatiles[2] > 0 then
        self.player.volatiles[2] = self.player.volatiles[2] - 1
    end
    if self.enemy.volatiles[2] > 0 then
        self.enemy.volatiles[2] = self.enemy.volatiles[2] - 1
    end
    if self.player.volatiles[3] > 0 then
        self.player.volatiles[3] = self.player.volatiles[3] - 1
    end
    if self.enemy.volatiles[3] > 0 then
        self.enemy.volatiles[3] = self.enemy.volatiles[3] - 1
    end
    if self.player.volatiles[9] > 0 then
        self.player.volatiles[9] = self.player.volatiles[9] - 1
    end
    if self.enemy.volatiles[9] > 0 then
        self.enemy.volatiles[9] = self.enemy.volatiles[9] - 1
    end
    if self.player.volatiles[10] > 0 then
        self.player.volatiles[10] = self.player.volatiles[10] - 1
    end
    if self.enemy.volatiles[10] > 0 then
        self.enemy.volatiles[10] = self.enemy.volatiles[10] - 1
    end
    if self.player.volatiles[11] > 0 then
        self.player.volatiles[11] = self.player.volatiles[11] - 1
    end
    if self.enemy.volatiles[11] > 0 then
        self.enemy.volatiles[11] = self.enemy.volatiles[11] - 1
    end
end

return GameReader
