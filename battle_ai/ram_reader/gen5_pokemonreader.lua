dofile "./battle_ai/ram_reader/gen4_5_table.lua"

local bnd,br,bxr=bit.band,bit.bor,bit.bxor
local rshift, lshift=bit.rshift, bit.lshift

function mult32(a,b)
	local c=rshift(a,16)
	local d=a%0x10000
	local e=rshift(b,16)
	local f=b%0x10000
	local g=(c*f+d*e)%0x10000
	local h=d*f
	local i=g*0x10000+h
	return i
end

function getbits(a,b,d)
	return rshift(a,b)%lshift(1,d)
end

function gettop(a)
	return(rshift(a,16))
end

PokeReader = {}
PokeReader.__index = PokeReader

-- game: 1 = Diamond/Pearl, 2 = HeartGold/SoulSilver, 3 = Platinum, 4 = Black, 5 = White, 6 = Black 2, 7 = White 2
function PokeReader.new(game, gen)
    instance = setmetatable({}, PokeReader)
    instance.gen = gen
    instance.game = game
    instance.submode = 0
    instance.evs = {}
    instance.move = {}
    instance.movepp = {}
    instance.ivspart = {}
    return instance
end

function PokeReader:getPointer()
	if self.game == 1 then
		return memory.readdword(0x02106FAC)
	elseif self.game == 2 then
		return memory.readdword(0x0211186C)
	else -- game == 3
		return memory.readdword(0x02101D2C)
	end
	-- haven't found pointers for BW/B2W2, probably not needed anyway.
end

function PokeReader:getPidAddr(mode)
	if self.game == 1 then --Pearl
		enemyAddr = self.pointer + 0x364C8
		if mode == 5 then
			return self.pointer + 0x36C6C
		elseif mode == 4 then
			return memory.readdword(enemyAddr) + 0x774 + 0x5B0 + 0xEC*(self.submode-1)
		elseif mode == 3 then
			return memory.readdword(enemyAddr) + 0x774 + 0xB60 + 0xEC*(self.submode-1)
		elseif mode == 2 then
			return memory.readdword(enemyAddr) + 0x774 + 0xEC*(self.submode-1)
		else
			return self.pointer + 0xD2AC + 0xEC*(self.submode-1)
		end
	elseif self.game == 2 then --HeartGold
		enemyAddr = self.pointer + 0x37970
		if mode == 5 then
			return self.pointer + 0x38540
		elseif mode == 4 then
			return memory.readdword(enemyAddr) + 0x1C70 + 0xA1C + 0xEC*(self.submode-1)	
		elseif mode == 3 then
			return memory.readdword(enemyAddr) + 0x1C70 + 0x1438 + 0xEC*(self.submode-1)
		elseif mode == 2 then
			return memory.readdword(enemyAddr) + 0x1C70 + 0xEC*(self.submode-1)
		else
			return self.pointer + 0xD088 + 0xEC*(self.submode-1)
		end
	elseif self.game == 3 then --Platinum
		enemyAddr = self.pointer + 0x352F4
		if mode == 5 then
			return self.pointer + 0x35AC4
		elseif mode == 4 then
			return memory.readdword(enemyAddr) + 0x7A0 + 0x5B0 + 0xEC*(self.submode-1)
		elseif mode == 3 then
			return memory.readdword(enemyAddr) + 0x7A0 + 0xB60 + 0xEC*(self.submode-1) 
		elseif mode == 2 then
			return memory.readdword(enemyAddr) + 0x7A0 + 0xEC*(self.submode-1) 
		else
			return self.pointer + 0xD094 + 0xEC*(self.submode-1)
		end
	elseif self.game == 4 then --Black
		if mode == 5 then
			return 0x02259DD8
		elseif mode == 4 then
			return 0x0226B7B4 + 0xDC*(self.submode-1)
		elseif mode == 3 then
			return 0x0226C274 + 0xDC*(self.submode-1)
		elseif mode == 2 then
			return 0x0226ACF4 + 0xDC*(self.submode-1)
		else -- mode 1
			return 0x022349B4 + 0xDC*(self.submode-1) 
		end
	elseif self.game == 5 then --White
		if mode == 5 then
			return 0x02259DF8
		elseif mode == 4 then
			return 0x0226B7D4 + 0xDC*(self.submode-1)
		elseif mode == 3 then
			return 0x0226C294 + 0xDC*(self.submode-1)	
		elseif mode == 2 then
			return 0x0226AD14 + 0xDC*(self.submode-1)
		else -- mode 1
			return 0x022349D4 + 0xDC*(self.submode-1) 
            -- Spanish Version
            --return 0x02234974 + 0xDC*(submode-1)
		end
	elseif self.game == 6 then --Black 2
		if mode == 5 then
			return 0x0224795C
		elseif mode == 4 then
			return 0x022592F4 + 0xDC*(self.submode-1)
		elseif mode == 3 then
			return 0x02259DB4 + 0xDC*(self.submode-1)			
		elseif mode == 2 then
			return 0x02258834 + 0xDC*(self.submode-1)
		else -- mode 1
			return 0x0221E3EC + 0xDC*(self.submode-1)
		end
	else --White 2
		if mode == 5 then
			return 0x0224799C
		elseif mode == 4 then
			return 0x02259334 + 0xDC*(self.submode-1)
		elseif mode == 3 then
			return 0x02259DF4 + 0xDC*(self.submode-1)
		elseif mode == 2 then
			return 0x02258874 + 0xDC*(self.submode-1)
		else -- mode 1
            -- print(self)
			return 0x0221E42C + 0xDC*(self.submode-1)
		end
	end
end

-- mode: 1 = Party, 2 = Enemy, 3 = Enemy 2, 4 = Ally, 5 == Wild Pokemon
function PokeReader:get(mode)
    party = {}
    for q = 1, 6 do
        self.submode = q
        self.pointer = self:getPointer()
        self.pidAddr = self:getPidAddr(mode)
        self.pid = memory.readdword(self.pidAddr)
        self.checksum = memory.readword(self.pidAddr + 6)
        self.shiftvalue = (rshift((bnd(self.pid,0x3E000)),0xD)) % 24
        
        self.BlockAoff = (BlockA[self.shiftvalue + 1] - 1) * 32
        self.BlockBoff = (BlockB[self.shiftvalue + 1] - 1) * 32
        self.BlockCoff = (BlockC[self.shiftvalue + 1] - 1) * 32
        self.BlockDoff = (BlockD[self.shiftvalue + 1] - 1) * 32
        
        -- Block A
        self.prng = self.checksum
        for i = 1, BlockA[self.shiftvalue + 1] - 1 do
            self.prng = mult32(self.prng,0x5F748241) + 0xCBA72510 -- 16 cycles
        end
                
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.pokemonID = bxr(memory.readword(self.pidAddr + self.BlockAoff + 8), gettop(self.prng))
        if self.gen == 4 and self.pokemonID > 494 then --just to make sure pokemonID is right (gen 4)
            self.pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
        elseif self.gen == 5 and self.pokemonID > 651 then -- gen5
            self.pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
        end

        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.heldItem = bxr(memory.readword(self.pidAddr + self.BlockAoff + 2 + 8), gettop(self.prng))
        if self.gen == 4 and self.heldItem > 537 then -- Gen 4
            self.pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
        elseif self.gen == 5 and self.heldItem > 639 then -- Gen 5
            self.pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
        end
        
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.OTID = bxr(memory.readword(self.pidAddr + self.BlockAoff + 4 + 8), gettop(self.prng))
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.OTSID = bxr(memory.readword(self.pidAddr + self.BlockAoff + 6 + 8), gettop(self.prng))
        
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.ability = bxr(memory.readword(self.pidAddr + self.BlockAoff + 12 + 8), gettop(self.prng))
        self.friendship_or_steps_to_hatch = getbits(self.ability, 0, 8)
        self.ability = getbits(self.ability, 8, 8)
        if self.gen == 4 and self.ability > 123 then
            self.pokemonID = -1 -- (pokemonID = -1 indicates invalid data)
        elseif self.gen == 5 and self.ability > 164 then
            self.pokemonID = -1
        end
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.evs[1] = bxr(memory.readword(self.pidAddr + self.BlockAoff + 16 + 8), gettop(self.prng))
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.evs[2] = bxr(memory.readword(self.pidAddr + self.BlockAoff + 18 + 8), gettop(self.prng))
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.evs[3] = bxr(memory.readword(self.pidAddr + self.BlockAoff + 20 + 8), gettop(self.prng))
        
        self.hpev =  getbits(self.evs[1], 0, 8)
        self.atkev = getbits(self.evs[1], 8, 8)
        self.defev = getbits(self.evs[2], 0, 8)
        self.speev = getbits(self.evs[2], 8, 8)
        self.spaev = getbits(self.evs[3], 0, 8)
        self.spdev = getbits(self.evs[3], 8, 8)
        
        -- Block B
        self.prng = self.checksum
        for i = 1, BlockB[self.shiftvalue + 1] - 1 do
            self.prng = mult32(self.prng,0x5F748241) + 0xCBA72510 -- 16 cycles
        end
        
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.move[1] = bxr(memory.readword(self.pidAddr + self.BlockBoff + 8), gettop(self.prng))
        if self.gen == 4 and self.move[1] > 467 then
            self.pokemonID = -1
        elseif self.gen == 5 and self.move[1] > 559 then
            self.pokemonID = -1
        end
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.move[2] = bxr(memory.readword(self.pidAddr + self.BlockBoff + 2 + 8), gettop(self.prng))
        if self.gen == 4 and self.move[2] > 467 then
            self.pokemonID = -1
        elseif self.gen == 5 and self.move[2] > 559 then
            self.pokemonID = -1
        end
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.move[3] = bxr(memory.readword(self.pidAddr + self.BlockBoff + 4 + 8), gettop(self.prng))
        if self.gen == 4 and self.move[3] > 467 then
            self.pokemonID = -1
        elseif self.gen == 5 and self.move[3] > 559 then
            self.pokemonID = -1
        end
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.move[4] = bxr(memory.readword(self.pidAddr + self.BlockBoff + 6 + 8), gettop(self.prng))
        if self.gen == 4 and self.move[4] > 467 then
            self.pokemonID = -1
        elseif self.gen == 5 and self.move[4] > 559 then
            self.pokemonID = -1
        end
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.moveppaux = bxr(memory.readword(self.pidAddr + self.BlockBoff + 8 + 8), gettop(self.prng))
        self.movepp[1] = getbits(self.moveppaux,0,8)
        self.movepp[2] = getbits(self.moveppaux,8,8)
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.moveppaux = bxr(memory.readword(self.pidAddr + self.BlockBoff + 10 + 8), gettop(self.prng))
        self.movepp[3] = getbits(self.moveppaux,0,8)
        self.movepp[4] = getbits(self.moveppaux,8,8)
        
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.ivspart[1] = bxr(memory.readword(self.pidAddr + self.BlockBoff + 16 + 8), gettop(self.prng))
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.ivspart[2] = bxr(memory.readword(self.pidAddr + self.BlockBoff + 18 + 8), gettop(self.prng))
        self.ivs = self.ivspart[1]  + lshift(self.ivspart[2],16)
        
        self.hpiv  = getbits(self.ivs,0,5)
        self.atkiv = getbits(self.ivs,5,5)
        self.defiv = getbits(self.ivs,10,5)
        self.speiv = getbits(self.ivs,15,5)
        self.spaiv = getbits(self.ivs,20,5)
        self.spdiv = getbits(self.ivs,25,5)
        self.isegg = getbits(self.ivs,30,1)
        
        -- Nature for gen 5, for gen 4, it's calculated from the PID.
        if self.gen == 5 then
            self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
            self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
            self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
            self.nat = bxr(memory.readword(self.pidAddr + self.BlockBoff + 24 + 8), gettop(self.prng))
            self.nat = getbits(self.nat,8,8)
            if self.nat > 24 then
                self.pokemonID = -1
            end
        else -- gen == 4
            self.nat = self.pid % 25
        end
        

        -- Block C
        self.prng = self.checksum
        for i = 1, BlockC[self.shiftvalue + 1] - 1 do
            self.prng = mult32(self.prng,0x5F748241) + 0xCBA72510 -- 16 cycles
        end

        -- self.nickname = {}

        
                
        self.nickname = {}
        for i = 1, 11 do
            self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
            letter = getbits(bxr(memory.readword(self.pidAddr + self.BlockCoff + 8 + 2*(i-1)), gettop(self.prng)), 0, 8)
            if letter == 255 then break end
            self.nickname[i] = string.char(letter)
        end


        -- Block D
        self.prng = self.checksum
        for i = 1, BlockD[self.shiftvalue + 1] - 1 do
            self.prng = mult32(self.prng,0x5F748241) + 0xCBA72510 -- 16 cycles
        end
        
        self.prng = mult32(self.prng,0xCFDDDF21) + 0x67DBB608 -- 8 cycles
        self.prng = mult32(self.prng,0xEE067F11) + 0x31B0DDE4 -- 4 cycles
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.pkrs = bxr(memory.readword(self.pidAddr + self.BlockDoff + 0x1A + 8), gettop(self.prng))
        self.pkrs = getbits(self.pkrs,0,8)
        
        -- Current stats
        self.prng = self.pid
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.level = getbits(bxr(memory.readword(self.pidAddr + 0x8C), gettop(self.prng)),0,8)
        self.prng = mult32(self.prng,0x41C64E6D) + 0x6073
        self.hpstat = bxr(memory.readword(self.pidAddr + 0x8E), gettop(self.prng))
        --print("Current HP of pokemon in slot " .. q .. ": " .. hpstat)
        
        if self.pokemonID ~= -1 then
            tbl = {}
            if pokemon[self.pokemonID + 1] ~= "none" then
                tbl.name = pokemon[self.pokemonID+1]
                tbl.ability = abilities[self.ability+1]
                tbl.nature = nature[self.nat+1]
                tbl.moves = {}
                tbl.moves[1] = movename[self.move[1] + 1]
                tbl.moves[2] = movename[self.move[2] + 1]
                tbl.moves[3] = movename[self.move[3] + 1]
                tbl.moves[4] = movename[self.move[4] + 1]
                tbl.evs = { self.hpev, self.atkev, self.defev, self.spaev, self.spdev, self.speev }
                tbl.ivs = { self.hpiv, self.atkiv, self.defiv, self.spaiv, self.spdiv, self.speiv }
                tbl.level = self.level
                tbl.item = item_gen5[self.heldItem+1]
                tbl.happiness = self.friendship_or_steps_to_hatch
                tbl.nickname = table.concat(self.nickname)
            end
            party[q] = tbl
        end
    end
    return party
end

return PokeReader