SHOWDOWN_FILE = "./showdown/pokemon-showdown"
FORMAT = "gen8nationaldex"
team1 =
    "Articuno|||pressure|leechseed,confuseray,spikes,|Modest|252,,,252,4,||,,,30,30,|||]Ludicolo||lifeorb|swiftswim|surf,gigadrain,icebeam,raindance|Modest|4,,,252,,252|||||]Volbeat||damprock|prankster|tailglow,batonpass,encore,raindance|Bold|248,,252,,8,|M||||]Seismitoad||lifeorb|swiftswim|hydropump,earthpower,stealthrock,raindance|Modest|,,,252,4,252|||||]Alomomola||damprock|regenerator|wish,protect,toxic,raindance|Bold|252,,252,,4,|||||]Armaldo||leftovers|swiftswim|xscissor,stoneedge,aquatail,rapidspin|Adamant|128,252,4,,,124|||||"
team2 =
    "Mewtwo|||pressure|toxicspikes,stealthrock,reflect,|Modest|252,,,252,4,||,,,30,30,|||]Ludicolo||lifeorb|swiftswim|surf,gigadrain,icebeam,raindance|Modest|4,,,252,,252|||||]Volbeat||damprock|prankster|tailglow,batonpass,encore,raindance|Bold|248,,252,,8,|M||||]Seismitoad||lifeorb|swiftswim|hydropump,earthpower,stealthrock,raindance|Modest|,,,252,4,252|||||]Alomomola||damprock|regenerator|wish,protect,toxic,raindance|Bold|252,,252,,4,|||||]Armaldo||leftovers|swiftswim|xscissor,stoneedge,aquatail,rapidspin|Adamant|128,252,4,,,124|||||"

sf = string.format
showdown_init = sf("%s simulate-battle", SHOWDOWN_FILE)

ps_stream = io.popen(showdown_init, "w")
-- io.stdout:setvbuf 'no' 

ps_stream:write(sf([[>start {"formatid": "%s"}]] .. "\n", FORMAT) .. "\n")
ps_stream:write(sf([[>player p1 {"name":"A", "team": "%s"}]], team1) .. "\n")
ps_stream:write(sf([[>player p2 {"name":"B", "team": "%s"}]], team2) .. "\n")
ps_stream:write([[>p1 team 123456]] .. "\n")
ps_stream:write([[>p2 team 12345]] .. "\n")
ps_stream:write([[>p1 move 1]] .. "\n")
ps_stream:write([[>p2 move 3]] .. "\n")
ps_stream:flush()
-- while true do print(test_file:read("a")) end

lines = {}
for element in io.lines("last.txt") do
    table.insert(lines, element)
end
-- test_file = io.open("last.txt", "r")
-- line_iter = test_file:lines()
-- for i = 0, 100, 1 do
--     print(line_iter())
-- end

-- print("new turn\n\n\n\n\n\n")

-- ps_stream:write([[>p1 move 2]] .. "\n")
-- ps_stream:write([[>p2 move 1]] .. "\n")

-- for i = 0, 100, 1 do
--     print(line_iter())
-- end

ps_stream:close()

-- if I do process_logs in lua:
---    I can just run that, analyze the log from last.txt and
---    then just pass that value into the neural network as state

-- log_stream = io.popen("python3 process_logs.py", "w")
-- print(log_stream:read("a"))
-- log_stream:close()
