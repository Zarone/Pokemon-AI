battle.ts

    let fs = require("fs");

battle.ts (Battle.runAction right at the beggining of case start, set relevant battle data)

    // read state from battleState.json

    fs.readFile("./battleState.json", "utf8", (err: any, data: any) => {
    		if (err) {
    			console.log(`Error reading file from disk: ${err}`);
    		} else {
    			// parse JSON string to JSON object
    			const databases = JSON.parse(data);

    			console.log(databases);
    		}
    	});

    // the variables if I want to set

    this.field.weather
    this.field.getWeather().duration - field.weatherState.duration
    this.sides[1].pokemon[0].status
    Object.keys(this.sides[1].pokemon[0].volatiles)
    this.sides[0].pokemon[0].hp
    this.sides[0].pokemon[0].types
    this.sides[0].pokemon[0].boosts
    this.sides[0].pokemon[0].level
    this.sides[1].pokemon[0].baseSpecies.name
    this.sides[0].sideConditions.spikes
    this.sides[0].sideConditions.spikes.id
    this.sides[0].sideConditions.spikes.layers
    this.sides[0].sideConditions.stealthrock
    this.sides[1].sideConditions.stealthrock.id
    this.sides[0].sideConditions.stealthrock.layers

pokemon-showdown

    // this saves the game log to a file
    let logFile = fs.createWriteStream("last_log.txt");
    battleStream.pipeTo(logFile, { noEnd: true });
