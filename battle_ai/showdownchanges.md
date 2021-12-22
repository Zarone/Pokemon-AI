battle.ts

    let fs = require("fs");
    fs.readFile("./battleState.json", "utf8", (err: any, data: any) => {
    		if (err) {
    			console.log(`Error reading file from disk: ${err}`);
    		} else {
    			// parse JSON string to JSON object
    			const databases = JSON.parse(data);

    			console.log(databases);
    		}
    	});


    // the variables if I want to set them in future

    console.log("weatherType: ", this.field.weather);
    console.log(
    	"weatherTurn: ",
    	this.field.getWeather().duration - field.weatherState.duration
    );
    console.log("status", this.sides[1] && this.sides[1].pokemon[0].status);
    console.log(
    		"volatiles",
    		// this.sides[0] && this.sides[0].pokemon[0].volatiles,
    		this.sides[1] &&
    			this.sides[1].pokemon[0].volatiles &&
    			Object.keys(this.sides[1].pokemon[0].volatiles)
    	);
    console.log("hp", this.sides[0] && this.sides[0].pokemon[0].hp);
    console.log("types", this.sides[0] && this.sides[0].pokemon[0].types);
    console.log("boosts", this.sides[0] && this.sides[0].pokemon[0].boosts);
    console.log("level", this.sides[0] && this.sides[0].pokemon[0].level);
    console.log(
    	"baseSpecies.name",
    	this.sides[1] && this.sides[1].pokemon[0].baseSpecies.name
    );
    console.log(
    		this.sides[0] &&
    		this.sides[0].sideConditions.spikes &&
    		this.sides[0].sideConditions.spikes.id
    );
    console.log(
    	this.sides[0] &&
    		this.sides[0].sideConditions.spikes &&
    		this.sides[0].sideConditions.spikes.layers
    );
    console.log(
    	this.sides[1] &&
    		this.sides[1].sideConditions.stealthrock &&
    		this.sides[1].sideConditions.stealthrock.id
    );
    console.log(
    	this.sides[0] &&
    		this.sides[0].sideConditions.stealthrock &&
    		this.sides[0].sideConditions.stealthrock.layers
    );

pokemon-showdown

    battleStream.pipeTo(logFile, { noEnd: true });
