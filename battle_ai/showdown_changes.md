battle.ts

    let fs = require("fs");

battle.ts

    this.send() // sends info to stream for debugging
    console.log() // also sends to lua console for some reason

    // appended to constructor
    // read state from battleState.json
    // current this sets weather
    importData: any;
    constructor(options: BattleOptions) {

        let data = fs.readFileSync(
            "./debug_tools/testing_battleState.json",
            "utf8"
        );

        // parse JSON string to JSON object
        const databases = JSON.parse(data);
        this.importData = databases;
        
        // ...
    }


    // inside Battle.runAction() under switch case "beforeTurn"

    // set weather
    if (this.importData.weather == 4) {
        //sand
        this.field.setWeather("Sandstorm", this.sides[0].active[0]);
        this.field.weatherState.duration =
        this.importData.turns_left_of_weather;
    } else if (this.importData.weather == 3) {
        //hail
        this.field.setWeather("hail", this.sides[0].active[0]);
        this.field.weatherState.duration =
        this.importData.turns_left_of_weather;
    } else if (this.importData.weather == 2) {
        //rain
        this.field.setWeather("RainDance", this.sides[0].active[0]);
        this.field.weatherState.duration =
        this.importData.turns_left_of_weather;
    } else if (this.importData.weather == 1) {
        // sun
        this.field.setWeather("sunnyday", this.sides[0].active[0]);
        this.field.weatherState.duration =
        this.importData.turns_left_of_weather;
    }


    // the variables if I want to set
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
    this.sides[0].active
    this.sides[1].active

pokemon-showdown

    // this saves the game log to a file
    let logFile = fs.createWriteStream("last_log.txt");
    battleStream.pipeTo(logFile, { noEnd: true });
