json = require "lunajson"
package.cpath = ";./battle_ai/backprop_ai/build/?.so"
processor = require "processor"
Writer = require "./battle_ai/showdown_writer"

function move_to_action(move)
    if move == 0 then
        return ">p1 move 1"
    elseif move == 1 then
        return ">p1 move 2"
    elseif move == 2 then
        return ">p1 move 3"
    elseif move == 3 then
        return ">p1 move 4"
    elseif move == 4 then
        return ">p1 switch 1"
    elseif move == 5 then
        return ">p1 switch 2"
    elseif move == 6 then
        return ">p1 switch 3"
    elseif move == 7 then
        return ">p1 switch 4"
    elseif move == 8 then
        return ">p1 switch 5"
    elseif move == 9 then
        return ">p1 switch 6"
    end
end

function exec_showdown_state(
    state, activeP1, activeP2, encoreP1, encoreP2, disabledP1, disabledP2, secP1, secP2
)
    stateFile = io.open("./battle_ai/state_files/battleStateForShowdown.json", "w")
    stateFile:write(
        json.encode({state, "", activeP1, activeP2, encoreP1, encoreP2, disabledP1, disabledP2, secP1, secP2})
    )
    stateFile:close()
    Writer.exec()
end

startupInfo = {
    {
        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0,

        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0,

        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,

        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0,

        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0,

        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0,
        100, 92, 105, 90, 125,
        
        90, 98, 0, 0, 0, 
        0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0,
        100, 70, 105, 125, 65,
        
        75, 45, 0, 0, 0, 
        0, 0, 0, 0, 0, 

        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0,

        0, 0, 0, 0, 0,
        100, 90, 92, 87, 75,

        85, 76, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        1, 65, 95, 85, 55, 
        
        55, 85, 0, 0, 0,
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        100, 106, 110, 90, 154, 
        
        90, 130, 0, 0, 0,
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0,

        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0,
        100, 89, 124, 80, 55,
        
        80, 55, 0, 0, 0,
        0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 
        100, 58, 50, 145, 95,

        105, 30, 0, 0, 0, 
        0, 0, 0, 0, 0,
        
        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        100, 70, 80, 70, 80, 
        
        70, 110, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        100, 150, 80, 44, 90, 
        
        54, 80, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        0, 100, 60, 70, 85, 
        
        105, 60, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 1,
        100, 60, 55, 90, 145, 
        
        90, 80, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 
        
        0, 0, 0, 0, 0
    },
    "not switch",
    0,
    3,
    "dracometeor",
    "",
    "darkpulse",
    "",
    0,
    0
}

stateFile = io.open("./battle_ai/state_files/battleStateForShowdown.json", "w")
stateFile:write(json.encode(startupInfo))
stateFile:close()

team1 = "Mew2|Mewtwo|none|Pressure|psychocut,disable,futuresight,guardswap|Modest|0,0,0,0,0,0||7,16,30,13,12,5||70|72,,]Crustle||none|Sturdy|bugbite,stealthrock,rockslide,slash|Docile|0,0,0,0,0,0||20,0,7,16,26,20||35|72,,]Nidoqueen||none|Poison Point|toxicspikes,superpower,earthpower,furyswipes|Sassy|85,85,85,85,85,85||31,31,31,31,31,31||100|76,,]Qwilfish||Focus Sash|Swift Swim|spikes,pinmissile,takedown,aquatail|Quirky|0,0,0,0,0,0||15,9,22,12,18,14||47|72,,]Hydreigon||Choice Specs|Levitate|dracometeor,fly,darkpulse,focusblast|Timid|6,0,0,252,0,252||31,31,31,31,31,31||100|255,," 
team2 = "Cofagrigus||none|Mummy|shadowball,psychic,willowisp,energyball|Sassy|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Jellicent||none|Cursed Body|shadowball,psychic,hydropump,sludgewave|Careful|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Froslass||none|Snow Cloak|shadowball,psychic,blizzard,iceshard|Impish|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Drifblim||none|Aftermath|shadowball,psychic,acrobatics,thunder|Quirky|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Golurk||none|Iron Fist|shadowpunch,earthquake,hammerarm,curse|Jolly|0,0,0,0,0,0||30,30,30,30,30,30||71|255,,]Chandelure||none|Flame Body|shadowball,psychic,fireblast,payback|Calm|0,0,0,0,0,0||30,30,30,30,30,30||73|255,,"
startup = io.open("./battle_ai/state_files/startInfoForShowdown.json", "w")
startup:write(json.encode({ ["format"]="gen5ubers", ["team1"] = team1, ["team2"] = team2 }))
startup:close()

SHOWDOWN_FILE = "node ./battle_ai/showdown/pokemon-showdown"
showdown_init = sf("%s vanilla-simulation", SHOWDOWN_FILE)
ps_stream = io.popen(showdown_init, "w")

firstState = io.open("./battle_ai/state_files/thisCurrentState.json", "w")
firstState:write(json.encode(startupInfo))
firstState:close()

for i = 0, 1 do

    
    -- local decode = ""
    
    -- while decode == "" do
    --     local readStartupInfo = io.open("./battle_ai/state_files/thisCurrentState.json", "r")
    --     decode = readStartupInfo:read("a")
    --     readStartupInfo:close()
    -- end
    local readStartupInfo = io.open("./battle_ai/state_files/thisCurrentState.json", "r")
    decode = readStartupInfo:read("a")
    readStartupInfo:close()
    print("decode: ", decode)
    decode = json.decode(decode)
    -- print(decode)
    
    firstState = io.open("./battle_ai/state_files/thisCurrentState.json", "w")
    firstState:write("")
    firstState:close()

    print(decode[1][65 + 30 * 0 + 1])
    print(decode[1][65 + 30 * 1 + 1])
    print(decode[1][65 + 30 * 2 + 1])
    print(decode[1][65 + 30 * 3 + 1])
    print(decode[1][65 + 30 * 4 + 1])
    print(decode[1][65 + 30 * 5 + 1])

    ps_stream:write(">p2 default\n")
    ps_stream:write(">p1 default\n")
    -- p1_move = processor.get_move(exec_showdown_state, decode)
    -- print(move_to_action(p1_move))
    -- ps_stream:write(move_to_action(p1_move))


    -- local start = os.time()
    -- repeat until os.time() > start + 5
end