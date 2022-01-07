-- Battle PRNG State: 021F6388

function read_halfword(address)
    range = memory.readbyterange(address, 2)
    return range[2]*256+range[1]
end

function get_battle_slot(num)
    return 0x0226F026 + num*(9+16*33+11)
end

function get_possible_evs_ivs_nature(stat)

end

function check_mem_in_battle_slot(num)
    -- current HP: read_halfword(get_battle_slot(num) + 62)
    -- max hp: read_halfword(get_battle_slot(num) + 60)
    -- current atk: read_halfword(get_battle_slot(num) + 284)
    -- current def: read_halfword(get_battle_slot(num) + 286)
    -- current spa: read_halfword(get_battle_slot(num) + 288)
    -- current spd: read_halfword(get_battle_slot(num) + 290)
    -- current spe: read_halfword(get_battle_slot(num) + 292)
    -- is paralyzed: read_halfword(get_battle_slot(num) + 78) 
    -- is sleeping: 82
    -- is frozen: 86
    -- is burned: read_halfword(get_battle_slot(num) + 90) 
    -- is poisoned, val is 121 if toxic: read_halfword(get_battle_slot(num) + 94) 
    -- turns of sleep: memory.readbyte(get_battle_slot(num) + 220)
    
    -- atk boost: memory.readbyte(get_battle_slot(num) + 298 )
    -- def boost: memory.readbyte(get_battle_slot(num) + 299 )
    -- spa boost: memory.readbyte(get_battle_slot(num) + 300 )
    -- spd boost: memory.readbyte(get_battle_slot(num) + 301 )
    -- spe boost: memory.readbyte(get_battle_slot(num) + 302 )
    -- accuracy boost: memory.readbyte(get_battle_slot(num) + 303 )
    -- evasion boost: memory.readbyte(get_battle_slot(num) + 304 )

    -- possible IV spread: 365-270
    -- possible EV spread: 359-364

    -- print(read_halfword(get_battle_slot(num) + 60))
    -- print(read_halfword(get_battle_slot(num) + 284))
    -- print(read_halfword(get_battle_slot(num) + 286))
    -- print(read_halfword(get_battle_slot(num) + 288))
    -- print(read_halfword(get_battle_slot(num) + 290))
    -- print(read_halfword(get_battle_slot(num) + 292))

    for i = 0, 512 do
        print(i, memory.readbyte(get_battle_slot(num) + i))
    end


end

t = 0

function get_pokemon_info()

    if t > 90 then
        t = 0

        -- seems like positive numbers update faster
        -- in wild battle:
            -- -12, -7 are your pokemon
            -- -6 is your opponent
            -- -5, 0 are also your pokemon
            -- 1 is your opponent
        -- in trainer battle:
            -- -12, -7 are your pokemon
            -- -6, -1 are your opponent'
            -- 0, 5 are your pokemon
            -- 6, 11 are your opponent's


        -- check_mem_in_battle_slot(-12)
        -- check_mem_in_battle_slot(-11)
        -- check_mem_in_battle_slot(-10)
        -- check_mem_in_battle_slot(-9)
        -- check_mem_in_battle_slot(-8)
        -- check_mem_in_battle_slot(-7)

        -- check_mem_in_battle_slot(-6)
        -- check_mem_in_battle_slot(-5)
        -- check_mem_in_battle_slot(-4)
        -- check_mem_in_battle_slot(-3)
        -- check_mem_in_battle_slot(-2)
        -- check_mem_in_battle_slot(-1)

        check_mem_in_battle_slot(0)
        -- check_mem_in_battle_slot(1)
        -- check_mem_in_battle_slot(2)
        -- check_mem_in_battle_slot(3)
        -- check_mem_in_battle_slot(4)
        -- check_mem_in_battle_slot(5)

        -- check_mem_in_battle_slot(6)
        -- check_mem_in_battle_slot(7)
        -- check_mem_in_battle_slot(8)
        -- check_mem_in_battle_slot(9)
        -- check_mem_in_battle_slot(10)
        -- check_mem_in_battle_slot(11)

    else
        t = t + 1
    end
end

-- last_str = ""
-- function fn()
--     str = {}
--     startChar = 0x02296380
--     endChar = startChar+2*memory.readbyte(0x0229637A)-1
--     for i = startChar, endChar , 2 do
--         byteVal = memory.readbyte(i)
--         if byteVal == 254 then
--             table.insert(str, " ")
--         else
--             table.insert(str, string.char(memory.readbyte(i)))
--         end
--     end
--     -- print(str)
--     new_str = table.concat(str, "")
--     if last_str ~= new_str then
--         print(new_str)
--     end
--     last_str = new_str
-- end

-- fn()

gui.register(get_pokemon_info)

-- can_attack: memory.readbyte(022A6A9D)
-- something to do with stealth rock: 0x21f4534
-- remaining turns of weather: memory.readbyte(021F63F8)
-- 1 when harsh sun: memory.readbyte(021F63F4)
-- 2 when rain:      memory.readbyte(021F63F4)
-- 3 when hail:      memory.readbyte(021F63F4)
-- 4 when sand:      memory.readbyte(021F63F4)
-- weather, backup 02269C0C
-- turns of trick room: 021F6440

-- battle prng state: 021F6388

-- check out for hazards 021F3CC7
-- toxic spikes goes off when this is 0: 021F3CB4

-- for substitute, 0226F246, or 0226D896
-- when sub is active it's value is 64 or "0100 0000" in binary