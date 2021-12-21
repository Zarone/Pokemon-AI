SHOWDOWN_FILE = "./showdown/pokemon-showdown"
FORMAT = "gen8nationaldex"
team1 = "Articuno|||pressure|leechseed,confuseray,spikes,|Modest|252,,,252,4,||,,,30,30,|||]Ludicolo||lifeorb|swiftswim|surf,gigadrain,icebeam,raindance|Modest|4,,,252,,252|||||]Volbeat||damprock|prankster|tailglow,batonpass,encore,raindance|Bold|248,,252,,8,|M||||]Seismitoad||lifeorb|swiftswim|hydropump,earthpower,stealthrock,raindance|Modest|,,,252,4,252|||||]Alomomola||damprock|regenerator|wish,protect,toxic,raindance|Bold|252,,252,,4,|||||]Armaldo||leftovers|swiftswim|xscissor,stoneedge,aquatail,rapidspin|Adamant|128,252,4,,,124|||||"
team2 = "Mewtwo|||pressure|toxicspikes,stealthrock,reflect,|Modest|252,,,252,4,||,,,30,30,|||]Ludicolo||lifeorb|swiftswim|surf,gigadrain,icebeam,raindance|Modest|4,,,252,,252|||||]Volbeat||damprock|prankster|tailglow,batonpass,encore,raindance|Bold|248,,252,,8,|M||||]Seismitoad||lifeorb|swiftswim|hydropump,earthpower,stealthrock,raindance|Modest|,,,252,4,252|||||]Alomomola||damprock|regenerator|wish,protect,toxic,raindance|Bold|252,,252,,4,|||||]Armaldo||leftovers|swiftswim|xscissor,stoneedge,aquatail,rapidspin|Adamant|128,252,4,,,124|||||"

showdown_init = string.format(
    [[echo '>start {"formatid": "%s"}
>player p1 {"name":"A", "team": "%s"}
>player p2 {"name":"B", "team": "%s"}
>p1 team 123456
>p2 team 123456
>p1 move 1
>p2 move 3
' | %s simulate-battle]],
    FORMAT, team1, team2, SHOWDOWN_FILE)

-- print(showdown_init)

function find_next_move(player)
    -- obviously a placeholder for a real find next move function
    if player == 1 then
        return ">p1 move 1"
    elseif player == 2 then
        return ">p2 move 1"
    end
end

ps_stream = io.popen(showdown_init, "w")
ps_stream:close()

-- if I do process_logs in lua:
---    I can just run that, analyze the log from last.txt and
---    then just pass that value into the neural network as state

-- log_stream = io.popen("python3 process_logs.py", "w")
-- print(log_stream:read("a"))
-- log_stream:close()