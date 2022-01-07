StateReader = {}

function read_halfword(address)
    range = memory.readbyterange(address, 2)
    return range[2] * 256 + range[1]
end

function get_battle_slot(num)
    return 0x0226F026 + num * (9 + 16 * 33 + 11)
end

function boosts_in_battle_slot(num)
    atk = memory.readbyte(get_battle_slot(num) + 298)
    def = memory.readbyte(get_battle_slot(num) + 299)
    spa = memory.readbyte(get_battle_slot(num) + 300)
    spd = memory.readbyte(get_battle_slot(num) + 301)
    spe = memory.readbyte(get_battle_slot(num) + 302)
    accuracy = memory.readbyte(get_battle_slot(num) + 303)
    evasion = memory.readbyte(get_battle_slot(num) + 304)
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

function StateReader.is_wild_battle()
    return read_halfword(get_battle_slot(-12) + 60) == read_halfword(get_battle_slot(-5) + 60) and
    read_halfword(get_battle_slot(-12) + 62) == read_halfword(get_battle_slot(-5) + 62)
end

function StateReader.get_enemy_status() 

    if self.is_wild_battle() then
        return {status_in_battle_slot(1)}
    else
        statuses = {}
        for i = -6, -1 do
            table.insert(statuses, status_in_battle_slot(i))
        end
        return statuses
    end

end

function StateReader.get_weather()
    return memory.readbyte(0x021F63F4)
end

function StateReader.get_remaining_weather_turns()
    return memory.readbyte(0x021F63F8)
end

return StateReader
