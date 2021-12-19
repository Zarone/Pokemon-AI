SHOWDOWN_FILE = "./showdown/pokemon-showdown"
FORMAT = "gen8nationaldex"
team1 = "Articuno||leftovers|pressure|icebeam,hurricane,substitute,roost|Modest|252,,,252,4,||,,,30,30,|||]Ludicolo||lifeorb|swiftswim|surf,gigadrain,icebeam,raindance|Modest|4,,,252,,252|||||]Volbeat||damprock|prankster|tailglow,batonpass,encore,raindance|Bold|248,,252,,8,|M||||]Seismitoad||lifeorb|swiftswim|hydropump,earthpower,stealthrock,raindance|Modest|,,,252,4,252|||||]Alomomola||damprock|regenerator|wish,protect,toxic,raindance|Bold|252,,252,,4,|||||]Armaldo||leftovers|swiftswim|xscissor,stoneedge,aquatail,rapidspin|Adamant|128,252,4,,,124|||||"
team2 = team1

showdown_init = string.format(
    [[echo '>start {"formatid": "%s"}
>player p1 {"name":"A", "team": "%s"}
>player p2 {"name":"B", "team": "%s"}
>p1 team 123456
>p2 team 123456
>p1 move 1
>p2 switch 3
' | %s simulate-battle]],
    FORMAT, team1, team2, SHOWDOWN_FILE)

-- print(showdown_init)

file = io.popen(showdown_init, "r")
res = file:read("*a")
file:close()
print(res)
