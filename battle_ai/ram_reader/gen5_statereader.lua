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

function StateReader.get_battle_slot(num)
    return get_battle_slot(num)
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
    return math.ceil(100 * read_halfword(get_battle_slot(num) + 62) / read_halfword(get_battle_slot(num) + 60))
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

function stats_in_battle_slot(num)
    local hp = memory.readbyte(get_battle_slot(num) + 60)
    atk = memory.readbyte(get_battle_slot(num) + 284)
    def = memory.readbyte(get_battle_slot(num) + 286)
    spa = memory.readbyte(get_battle_slot(num) + 288)
    spd = memory.readbyte(get_battle_slot(num) + 290)
    spe = memory.readbyte(get_battle_slot(num) + 292)
    return {hp, atk, def, spa, spd, spe}
end

function get_player_stats()
    stats = {}
    for i = -12, -7 do
        table.insert(stats, stats_in_battle_slot(i))
    end
    return stats
end

function get_enemy_stats()

    -- if it's a wild battle
    if (read_halfword(get_battle_slot(-12) + 60) == read_halfword(get_battle_slot(-5) + 60) and
        read_halfword(get_battle_slot(-12) + 62) == read_halfword(get_battle_slot(-5) + 62)) then
        -- return {stats_in_battle_slot(1)}
        return {stats_in_battle_slot(1), {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}}
    else
        stats = {}
        for i = -6, -1 do
            table.insert(stats, stats_in_battle_slot(i))
        end
        return stats
    end
end

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

function types_in_battle_slot(num)
    local type1 = memory.readbyte(get_battle_slot(num) + 294)
    local type2 = memory.readbyte(get_battle_slot(num) + 295)

    -- if ("Bug" in typelist):
    --     types[0] = 1
    -- if ("Dark" in typelist):
    --     types[1] = 1
    -- if ("Dragon" in typelist):
    --     types[2] = 1
    -- if ("Electric" in typelist):
    --     types[3] = 1
    -- if ("Fighting" in typelist):
    --     types[4] = 1
    -- if ("Fire" in typelist):
    --     types[5] = 1
    -- if ("Flying" in typelist):
    --     types[6] = 1
    -- if ("Ghost" in typelist):
    --     types[7] = 1
    -- if ("Grass" in typelist):
    --     types[8] = 1
    -- if ("Ground" in typelist):
    --     types[9] = 1
    -- if ("Ice" in typelist):
    --     types[10] = 1
    -- if ("Normal" in typelist):
    --     types[11] = 1
    -- if ("Poison" in typelist):
    --     types[12] = 1
    -- if ("Psychic" in typelist):
    --     types[13] = 1
    -- if ("Rock" in typelist):
    --     types[14] = 1
    -- if ("Steel" in typelist):
    --     types[15] = 1
    -- if ("Water" in typelist):
    --     types[16] = 1

    return {
        type1 == 6 or type2 == 6, -- bug
        type1 == 16 or type2 == 16, -- dark
        type1 == 15 or type2 == 15, -- dragon
        type1 == 12 or type2 == 12, -- electric
        type1 == 1 or type2 == 1, -- fighting
        type1 == 9 or type2 == 9, -- fire
        type1 == 2 or type2 == 2, -- flying
        type1 == 7 or type2 == 7, -- ghost
        type1 == 11 or type2 == 11, -- grass
        type1 == 4 or type2 == 4, -- ground
        type1 == 14 or type2 == 14, -- ice
        type1 == 0 or type2 == 0, -- normal
        type1 == 3 or type2 == 3, -- poison
        type1 == 13 or type2 == 13, -- psychic
        type1 == 5 or type2 == 5, -- rock
        type1 == 8 or type2 == 8, -- steel
        type1 == 10 or type2 == 10, -- water
    }
end

function get_enemy_types() 

    if StateReader.is_wild_battle() then
        return {types_in_battle_slot(1), 
            {0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0}, 
            {0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0}, 
            {0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0}, 
            {0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0}, 
            {0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0}, 
        }
    else
        types = {}
        for i = -6, -1 do
            table.insert(types, types_in_battle_slot(i))
        end
        return types
    end

end
function get_player_types()
    local types = {}
    for i = -12, -7 do
        table.insert(types, types_in_battle_slot(i))
    end
    return types
end

function StateReader.get_player_pokemon_array(pokemon_order)
    local Pokemon = {}
    local L_healths = StateReader.get_player_health()
    local L_stats = get_player_stats()
    local L_statuses = StateReader.get_player_status()
    local L_types = get_player_types()

    -- okay so types and stats for this export shouldn't matter I don't think
    -- since showdown doesn't read them

    -- although max hp must be greater than 1 for the way I setup showdown

    local index = 1
    for i = 1, 6 do
        local isFainted = 0
        if L_healths[i] < 1 then
            isFainted = 1
        end
        L_statuses[i][6] = isFainted
        -- local thisPokemon = {
        --     L_healths[i],
        --     -- unpack(L_stats[i]),
        --     1, 0, 0, 0, 0, 0,
        --     0, 0, 0, 0, 0,
        --     0, 0, 0, 0, 0,
        --     0, 0, 0, 0, 0,
        --     0, 0,
        --     unpack(L_statuses[i]),
        -- }
        local thisPokemon = { L_healths[i] }
        index = 2
        for j = index, index+7 do
            thisPokemon[j] = L_stats[i][j-index+1]
        end
        index = index + 6
        for j = index, index+18 do
            thisPokemon[j] = L_types[i][j-index+1]
        end
        index = index + 17
        for j = index, index+7 do
            thisPokemon[j] = L_statuses[i][j-index+1]
        end
        for j = 1, #thisPokemon do
            Pokemon[(i-1)*30+j] = thisPokemon[j]
        end
    end

    return Pokemon
end

function StateReader.get_enemy_pokemon_array(enemy_active)
    local Pokemon = {}
    local L_healths = StateReader.get_enemy_health()
    local L_statuses = StateReader.get_enemy_status()
    local L_stats = get_enemy_stats()
    local L_types = get_enemy_types()

    local index = 1
    for i = 1, 6 do
        local isFainted = 0
        if L_healths[i] < 1 then
            isFainted = 1
        end
        L_statuses[i][6] = isFainted
        -- local thisPokemon = {
        --     L_healths[i],
        --     -- unpack(L_stats[i]),
        --     1, 0, 0, 0, 0, 0,
        --     0, 0, 0, 0, 0,
        --     0, 0, 0, 0, 0,
        --     0, 0, 0, 0, 0,
        --     0, 0,
        --     unpack(L_statuses[i]),
        -- }
        local thisPokemon = { L_healths[i] }
        index = 2
        for j = index, index+7 do
            thisPokemon[j] = L_stats[i][j-index+1]
        end
        index = index + 6
        for j = index, index+18 do
            thisPokemon[j] = L_types[i][j-index+1]
        end
        index = index + 17
        for j = index, index+7 do
            thisPokemon[j] = L_statuses[i][j-index+1]
        end

        for j = 1, #thisPokemon do
            Pokemon[(i-1)*30+j] = thisPokemon[j]
        end
    end

    return Pokemon
end

return StateReader
