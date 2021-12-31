sf = string.format

Writer = {}
Writer.__index = Writer

function Writer.new(team1, team2)

    instance = setmetatable({}, Writer)
    SHOWDOWN_FILE = "node ./showdown/pokemon-showdown"
    
    -- mac: 
    -- SHOWDOWN_FILE = "./showdown/pokemon-showdown"
    -- windows: 
    -- SHOWDOWN_FILE = "node ./showdown/pokemon-showdown"
    
    FORMAT = "gen8nationaldex"
    Team1 = team1 or "Articuno|||pressure|leechseed,confuseray,spikes,|Modest|252,,,252,4,||,,,30,30,|||]Ludicolo||lifeorb|swiftswim|surf,gigadrain,icebeam,raindance|Modest|4,,,252,,252|||||]Volbeat||damprock|prankster|tailglow,batonpass,encore,raindance|Bold|248,,252,,8,|M||||]Seismitoad||lifeorb|swiftswim|hydropump,earthpower,stealthrock,raindance|Modest|,,,252,4,252|||||]Alomomola||damprock|regenerator|wish,protect,toxic,raindance|Bold|252,,252,,4,|||||]Armaldo||leftovers|swiftswim|xscissor,stoneedge,aquatail,rapidspin|Adamant|128,252,4,,,124|||||"
    Team2 = team2 or "Mewtwo|||pressure|toxicspikes,stealthrock,reflect,|Modest|252,,,252,4,||,,,30,30,|||]Ludicolo||lifeorb|swiftswim|surf,gigadrain,icebeam,raindance|Modest|4,,,252,,252|||||]Volbeat||damprock|prankster|tailglow,batonpass,encore,raindance|Bold|248,,252,,8,|M||||]Seismitoad||lifeorb|swiftswim|hydropump,earthpower,stealthrock,raindance|Modest|,,,252,4,252|||||]Alomomola||damprock|regenerator|wish,protect,toxic,raindance|Bold|252,,252,,4,|||||]Armaldo||leftovers|swiftswim|xscissor,stoneedge,aquatail,rapidspin|Adamant|128,252,4,,,124|||||"

    showdown_init = sf("%s simulate-battle", SHOWDOWN_FILE)

    instance.ps_stream = io.popen(showdown_init, "w")

    instance.ps_stream:write(sf([[>start {"formatid": "%s"}]] .. "\n", FORMAT) .. "\n")
    instance.ps_stream:write(sf([[>player p1 {"name":"A", "team": "%s"}]], team1) .. "\n")
    instance.ps_stream:write(sf([[>player p2 {"name":"B", "team": "%s"}]], team2) .. "\n")
    instance.ps_stream:write([[>p1 team 123456]] .. "\n")
    instance.ps_stream:write([[>p2 team 123456]] .. "\n")

    return instance
end

function Writer:close()
    self.ps_stream:close()
    print("stream successfully closed")
end

return { Writer = Writer }