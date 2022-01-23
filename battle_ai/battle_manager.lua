Writer = require "./battle_ai/showdown_writer"
PokeReader = require "./battle_ai/ram_reader/gen5_pokemonreader"
json = require "lunajson"
StateReader = require "./battle_ai/ram_reader/gen5_statereader"
GameReader = require "./battle_ai/ram_reader/gen5_logreader"

BattleManager = {}
BattleManager.__index = BattleManager

function BattleManager.new()
    
    instance_IGReader = PokeReader.new(4, 5)
    team1 = instance_IGReader:get(1)
    team2 = nil
    if StateReader.is_wild_battle() then
        team2 = instance_IGReader:get(5)
    else
        team2 = instance_IGReader:get(2)
    end
    str_team1 = Writer.to_packed_team(team1)
    str_team2 = Writer.to_packed_team(team2)
    -- instance.showdown_instance = x
    -- instance.showdown_instance:write(">p1 switch 2\n")
    -- instance.showdown_instance:write(">p2 switch 3\n")
    -- instance.showdown_instance:close()
    
    names = {}
    names_enemy = {}
    
    for i, v in pairs(team1) do
        table.insert(names, v.nickname)
    end
    for i, v in pairs(team2) do
        table.insert(names_enemy, v.nickname)
    end
    
    instance = setmetatable({
        game_reader = GameReader.new(StateReader.is_wild_battle(), names, names_enemy),
        IGReader = instance_IGReader,
        showdown_instance = nil,--Writer.new(str_team1, str_team2),
        queued_move = nil
    }, BattleManager)
    print(instance.showdown_instance)
    return instance
end



function BattleManager.act(self)
    -- print("act")
    -- get_line returns true when user can attack
    
    if self.game_reader:get_line() then
        if self.queued_move == nil then
            self.showdown_instance = Writer.new(str_team1, str_team2)
            self:get_action()
        end 
        return self.queued_move
    else
        if self.queued_move ~= nil then
            print("user can't attack")
            self.showdown_instance:close()
            self.queued_move = nil
        end
        return 0
    end

    -- either 0 for no action, 1 for moveslot 1... 4 for moveslot 4, 5 for switch to party slot 1, 10 for party slot 6 
end

function BattleManager:get_action()
    returnAction = 10 -- indicates moveslot 1
    
    self.queued_move = returnAction
end

function BattleManager:get_switch()
    return 6
end

return BattleManager

-- function BattleManager.can_attack()
--     return memory.readbyte(0x022A6A9D)
-- end

-- file = io.open("./state_files/battleState.json", "w")
-- file:write(
--     json.encode({
--         weather = StateReader.get_weather(),
--         turns_left_of_weather = StateReader.get_remaining_weather_turns(),
--         player = {
--             boosts = {StateReader.get_player_boosts()},
--             statuses = {StateReader.get_player_status()},
--             hazards = game_reader.player.hazards,
--             volatiles = game_reader.player.volatiles,
--             active = game_reader.active
--         },
--         enemy = {
--             boosts = {StateReader.get_enemy_boosts()},
--             statuses = {StateReader.get_enemy_status()},
--             hazards = game_reader.enemy.hazards,
--             volatiles = game_reader.enemy.volatiles,
--             active = game_reader.enemy_active
--         }
--     })
-- )