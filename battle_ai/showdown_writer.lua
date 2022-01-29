sf = string.format

Writer = {}
Writer.__index = Writer

function Writer.new(team1, team2)

    instance = setmetatable({}, Writer)
    -- SHOWDOWN_FILE = "node ./showdown/pokemon-showdown"
    SHOWDOWN_FILE = "node ./battle_ai/showdown/pokemon-showdown"

    -- mac: 
    -- SHOWDOWN_FILE = "./showdown/pokemon-showdown"
    -- windows: 
    -- SHOWDOWN_FILE = "node ./showdown/pokemon-showdown"

    FORMAT = "gen8nationaldex"
    team1 = team1 or
                "Reuniclus||Life Orb    |Magic Guard |trickroom,psychic,focusblast,shadowball     |Quiet   |192,0,64,252,0,0 ||31,31,30,31,31,2 ||72 |255 ,,]Crustle  ||none        |Sturdy      |bugbite,stealthrock,rockslide,slash         |Docile  |0,0,0,0,0,0      ||20,0,7,16,26,20  ||35 |70  ,,]Nidoqueen||none        |Poison Point|toxicspikes,superpower,earthpower,furyswipes|Sassy   |85,85,85,85,85,85||31,31,31,31,31,31||100|72  ,,]Qwilfish ||Focus Sash  |Swift Swim  |spikes,pinmissile,takedown,aquatail         |Quirky  |0,0,0,0,0,0      ||15,9,22,12,18,14 ||47 |70  ,,]Hydreigon||Choice Specs|Levitate    |dracometeor,fly,darkpulse,focusblast        |Timid   |6,0,0,252,0,252  ||31,31,31,31,31,31||100|255 ,,]Blaziken ||Leftovers   |Speed Boost |highjumpkick,rockslide,protect,flareblitz   |Adamant |4,252,0,0,0,252  ||31,31,31,24,31,31||77 |255 ,,"
    team2 = team2 or
                "Mewtwo|||pressure|toxicspikes,stealthrock,reflect,|Modest|252,,,252,4,||,,,30,30,|||]Ludicolo||lifeorb|swiftswim|surf,gigadrain,icebeam,raindance|Modest|4,,,252,,252|||||]Volbeat||damprock|prankster|tailglow,batonpass,encore,raindance|Bold|248,,252,,8,|M||||]Seismitoad||lifeorb|swiftswim|hydropump,earthpower,stealthrock,raindance|Modest|,,,252,4,252|||||]Alomomola||damprock|regenerator|wish,protect,toxic,raindance|Bold|252,,252,,4,|||||]Armaldo||leftovers|swiftswim|xscissor,stoneedge,aquatail,rapidspin|Adamant|128,252,4,,,124|||||"

    showdown_init = sf("%s simulate-battle", SHOWDOWN_FILE)
                
    print("running ", showdown_init )
    instance.ps_stream = io.popen(showdown_init, "w")

    instance.ps_stream:write(sf([[>start {"formatid": "%s"}]] .. "\n", FORMAT) .. "\n")
    instance.ps_stream:write(sf([[>player p1 {"name":"A", "team": "%s"}]], team1) .. "\n")
    instance.ps_stream:write(sf([[>player p2 {"name":"B", "team": "%s"}]], team2) .. "\n")
    instance.ps_stream:write([[>p1 team 123456]] .. "\n")
    instance.ps_stream:write([[>p2 team 123456]] .. "\n")

    return instance
end

function Writer:write(command)
    self.ps_stream:write(command)
end

function Writer:close()
    self.ps_stream:close()
    print("stream successfully closed")
end

function move_to_id(move)
    return move:gsub(" ", ""):gsub("-", ""):lower()
end

function moves_to_string(moves)
    -- print(moves)
    return move_to_id(moves[1]) .. "," .. move_to_id(moves[2]) .. "," .. move_to_id(moves[3]) .. "," ..
               move_to_id(moves[4])
end

-- for evs, ivs
function values_to_string(nums)
    return nums[1] .. "," .. nums[2] .. "," .. nums[3] .. "," .. nums[4] .. "," .. nums[5] .. "," .. nums[6]
end

function to_packed_pokemon(tbl)
    -- print(tbl)
    if tbl == nil then
        return ""
    else
        return
            tbl.name .. "||" .. tbl.item .. "|" .. tbl.ability .. "|" .. moves_to_string(tbl.moves) .. "|" .. tbl.nature ..
                "|" .. values_to_string(tbl.evs) .. "||" .. values_to_string(tbl.ivs) .. "||" .. tbl.level .. "|" ..
                tbl.happiness .. ",,"
    end
end

function Writer.to_packed_team(tbl)
    -- NICKNAME|SPECIES|ITEM|ABILITY|MOVES|NATURE|EVS|GENDER|IVS|SHINY|LEVEL|HAPPINESS,POKEBALL,HIDDENPOWERTYPE
    team_tbl = {}
    table.insert(team_tbl, to_packed_pokemon(tbl[1]))
    -- for k, v in pairs(tbl) do
    --     print(k)
    -- end
    for i = 2, #tbl, 1 do
        table.insert(team_tbl, "]")
        table.insert(team_tbl, to_packed_pokemon(tbl[i]))
    end
    return table.concat(team_tbl, "")

end

return Writer
