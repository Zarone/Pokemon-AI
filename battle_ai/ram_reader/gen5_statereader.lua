StateReader = {}

function read_halfword(address)
    range = memory.readbyterange(address, 2)
    return range[2] * 256 + range[1]
end

function get_battle_slot(num)
    return 0x0226F026 + num * (9 + 16 * 33 + 11)
end

function boosts_in_battle_slot(num)
    atk = memory.readbyte(get_battle_slot(num) + 298) - 6
    def = memory.readbyte(get_battle_slot(num) + 299) - 6
    spa = memory.readbyte(get_battle_slot(num) + 300) - 6
    spd = memory.readbyte(get_battle_slot(num) + 301) - 6
    spe = memory.readbyte(get_battle_slot(num) + 302) - 6
    accuracy = memory.readbyte(get_battle_slot(num) + 303) - 6
    evasion = memory.readbyte(get_battle_slot(num) + 304) - 6
    return {atk, def, spa, spd, spe, accuracy, evasion}
end

function status_in_battle_slot(num)
    return {
        memory.readbyte(get_battle_slot(num) + 78), -- paralyzed
        memory.readbyte(get_battle_slot(num) + 82), -- sleeping
        memory.readbyte(get_battle_slot(num) + 86), -- frozen
        memory.readbyte(get_battle_slot(num) + 90), -- burned
        memory.readbyte(get_battle_slot(num) + 94)  -- poisoned
    }
end

function health_in_battle_slot(num)
    return math.floor(100 * read_halfword(get_battle_slot(num) + 62) / read_halfword(get_battle_slot(num) + 60))
end

function StateReader.is_wild_battle()
    return read_halfword(get_battle_slot(-12) + 60) == read_halfword(get_battle_slot(-5) + 60) and
    read_halfword(get_battle_slot(-12) + 62) == read_halfword(get_battle_slot(-5) + 62)
end

-- current atk: read_halfword(get_battle_slot(num) + 284)
-- current def: read_halfword(get_battle_slot(num) + 286)
-- current spa: read_halfword(get_battle_slot(num) + 288)
-- current spd: read_halfword(get_battle_slot(num) + 290)
-- current spe: read_halfword(get_battle_slot(num) + 292)

-- function stats_in_battle_slot(num)
--     atk = memory.readbyte(get_battle_slot(num) + 284)
--     def = memory.readbyte(get_battle_slot(num) + 286)
--     spa = memory.readbyte(get_battle_slot(num) + 288)
--     spd = memory.readbyte(get_battle_slot(num) + 290)
--     spe = memory.readbyte(get_battle_slot(num) + 292)
--     return {atk, def, spa, spd, spe}
-- end

-- function get_player_stats()
--     stats = {}
--     for i = -12, -7 do
--         table.insert(stats, stats_in_battle_slot(i))
--     end
--     return stats
-- end

-- function get_enemy_stats()

--     -- if it's a wild battle
--     if (read_halfword(get_battle_slot(-12) + 60) == read_halfword(get_battle_slot(-5) + 60) and
--         read_halfword(get_battle_slot(-12) + 62) == read_halfword(get_battle_slot(-5) + 62)) then
--         return {stats_in_battle_slot(1)}
--     else
--         stats = {}
--         for i = -6, -1 do
--             table.insert(stats, stats_in_battle_slot(i))
--         end
--         return stats
--     end
-- end

function StateReader.get_player_boosts()
    boosts = {}
    for i = -12, -7 do
        table.insert(boosts, boosts_in_battle_slot(i))
    end
    return boosts
end

function StateReader.get_enemy_boosts()

    -- if it's a wild battle
    if (read_halfword(get_battle_slot(-12) + 60) == read_halfword(get_battle_slot(-5) + 60) and
        read_halfword(get_battle_slot(-12) + 62) == read_halfword(get_battle_slot(-5) + 62)) then
        return {boosts_in_battle_slot(1)}
    else
        boosts = {}
        for i = -6, -1 do
            table.insert(boosts, boosts_in_battle_slot(i))
        end
        return boosts
    end

end

function StateReader.get_player_status()
    statuses = {}
    for i = -12, -7 do
        table.insert(statuses, status_in_battle_slot(i))
    end
    return statuses
end

function StateReader.get_enemy_status() 

    if StateReader.is_wild_battle() then
        return {status_in_battle_slot(1), {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}}
    else
        statuses = {}
        for i = -6, -1 do
            table.insert(statuses, status_in_battle_slot(i))
        end
        return statuses
    end

end

function StateReader.get_player_health()
    health = {}
    for i = -12, -7 do
        table.insert(health, health_in_battle_slot(i))
    end
    return health
end

function StateReader.get_enemy_health() 
    if StateReader.is_wild_battle() then
        return {health_in_battle_slot(1), 0, 0, 0, 0, 0}
    else
        health = {}
        for i = -6, -1 do
            table.insert(health, health_in_battle_slot(i))
        end
        return health
    end

end

function StateReader.get_weather()
    return memory.readbyte(0x021F63F4)
end

function StateReader.get_remaining_weather_turns()
    return memory.readbyte(0x021F63F8)
end

function StateReader.get_player_pokemon_array()
    local Pokemon = {}
    local L_healths = StateReader.get_player_health()
    -- local L_stats = get_player_stats()
    local L_statuses = StateReader.get_player_status()

    -- okay so types and stats for this export shouldn't matter I don't think
    -- since showdown doesn't read them

    -- although max hp must be greater than 1 for the way I setup showdown

    for i = 1, 6 do
        local isFainted = 0
        if L_healths[i] < 1 then
            isFainted = 1
        end
        L_statuses[i][6] = isFainted
        local thisPokemon = {
            L_healths[i],
            -- unpack(L_stats[i]),
            1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0,
            unpack(L_statuses[i]),
        }
        for j = 1, #thisPokemon+1 do
            Pokemon[(i-1)*30+j] = thisPokemon[j]
        end
    end

    return Pokemon
end

function StateReader.get_enemy_pokemon_array()
    local Pokemon = {}
    local L_healths = StateReader.get_enemy_health()
    -- local L_stats = get_enemy_stats()
    local L_statuses = StateReader.get_enemy_status()

    -- okay so types for this export shouldn't matter I don't think
    -- since showdown doesn't read them

    -- although max hp must be greater than 1 for the way I setup showdown

    for i = 1, 6 do
        local isFainted = 0
        if L_healths[i] < 1 then
            isFainted = 1
        end
        L_statuses[i][6] = isFainted
        local thisPokemon = {
            L_healths[i],
            -- unpack(L_stats[i]),
            1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0,
            unpack(L_statuses[i]),
        }
        for j = 1, #thisPokemon+1 do
            Pokemon[(i-1)*30+j] = thisPokemon[j]
        end
    end

    return Pokemon
end

return StateReader
