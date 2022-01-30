battle.ts

    let fs = require("fs");

battle.ts


    // overwrote some random function to try and make the most likely events occur
    random(m?: number, n?: number) {
        if (m !== undefined && n !== undefined){
            return n*0.5 + m;
        } else if (m !== undefined){
            return m*0.5;
        } else {
            return 0.5
        }
		// return this.prng.next(m, n);
	}

	randomChance(numerator: number, denominator: number) {
        return numerator/denominator > 0.5;
		// return this.prng.randomChance(numerator, denominator);
	}

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


inside Battle.runAction() under switch case "start"

    // set status conditions and health
    for (let i = 0; i < 6; i++) {
        if (i < this.importData.player.statuses[0].length){

            this.sides[0].pokemon[i].sethp(this.importData.player.health[i])

            if (this.importData.player.statuses[0][i][0] == 1) {
                // paralysis
                this.sides[0].pokemon[i].setStatus("par");
            } else if (this.importData.player.statuses[0][i][1] == 1) {
                // sleep
                this.sides[0].pokemon[i].setStatus("slp");
            } else if (this.importData.player.statuses[0][i][2] == 1) {
                // freeze
                this.sides[0].pokemon[i].setStatus("frz");
            } else if (this.importData.player.statuses[0][i][3] == 1) {
                // burn
                this.sides[0].pokemon[i].setStatus("brn");
            } else if (this.importData.player.statuses[0][i][4] > 0) {
                // poison
                this.sides[0].pokemon[i].setStatus("psn");
            }
        }

        if (i < this.importData.enemy.statuses[0].length){
            this.sides[1].pokemon[i].sethp(this.importData.enemy.health[i])
            
            if (this.importData.enemy.statuses[0][i][0] == 1) {
                // paralysis
                this.sides[1].pokemon[i].setStatus("par");
            } else if (this.importData.enemy.statuses[0][i][1] == 1) {
                // sleep
                this.sides[1].pokemon[i].setStatus("slp");
            } else if (this.importData.enemy.statuses[0][i][2] == 1) {
                // freeze
                this.sides[1].pokemon[i].setStatus("frz");
            } else if (this.importData.enemy.statuses[0][i][3] == 1) {
                // burn
                this.sides[1].pokemon[i].setStatus("brn");
            } else if (this.importData.enemy.statuses[0][i][4] > 0) {
                // poison
                this.sides[1].pokemon[i].setStatus("psn");
            }
        }
    }


    // switch to correct 'mon

    // ...
    for (const side of this.sides) {
        for (let i = 0; i < side.active.length; i++) {
            if (!side.pokemonLeft) {
                // forfeited before starting
                side.active[i] = side.pokemon[i];
                side.active[i].fainted = true;
                side.active[i].hp = 0;
            } else {
                // this.actions.switchIn(side.pokemon[i], i);

                this.actions.switchIn(side.pokemon[i], i);
                if (side.id == "p1") {
                    this.actions.switchIn(
                        side.pokemon[this.importData.player.active],
                        i
                    );
                } else if (side.id == "p2") {
                    this.actions.switchIn(
                        side.pokemon[this.importData.enemy.active],
                        i
                    );
                }
            }
        }
    }
    // ...

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

    // set boosts
    let boost1 = {
        atk:
            this.importData.player.boosts[0][
                this.importData.player.active
            ][0] - 6,
        def:
            this.importData.player.boosts[0][
                this.importData.player.active
            ][1] - 6,
        spa:
            this.importData.player.boosts[0][
                this.importData.player.active
            ][2] - 6,
        spd:
            this.importData.player.boosts[0][
                this.importData.player.active
            ][3] - 6,
        spe:
            this.importData.player.boosts[0][
                this.importData.player.active
            ][4] - 6,
        accuracy:
            this.importData.player.boosts[0][
                this.importData.player.active
            ][5] - 6,
        evasion:
            this.importData.player.boosts[0][
                this.importData.player.active
            ][6] - 6,
    };

    let boost2 = {
        atk:
            this.importData.enemy.boosts[0][
                this.importData.enemy.active
            ][0] - 6,
        def:
            this.importData.enemy.boosts[0][
                this.importData.enemy.active
            ][1] - 6,
        spa:
            this.importData.enemy.boosts[0][
                this.importData.enemy.active
            ][2] - 6,
        spd:
            this.importData.enemy.boosts[0][
                this.importData.enemy.active
            ][3] - 6,
        spe:
            this.importData.enemy.boosts[0][
                this.importData.enemy.active
            ][4] - 6,
        accuracy:
            this.importData.enemy.boosts[0][
                this.importData.enemy.active
            ][5] - 6,
        evasion:
            this.importData.enemy.boosts[0][
                this.importData.enemy.active
            ][6] - 6,
    };

    this.sides[0].active[0].setBoost(boost1);
    this.sides[1].active[0].setBoost(boost2);

    // set volatile conditions
    if(this.importData.player.volatiles[0] == 1){
        this.sides[0].active[0].addVolatile("leechseed", this.sides[1].active[0])
    }
    if(this.importData.player.volatiles[1] == 1){
        this.sides[0].active[0].addVolatile("confusion")
    }
    if(this.importData.player.volatiles[2] != 0){
        this.sides[0].active[0].addVolatile("taunt")
    this.sides[0].active[0].volatiles["taunt"].duration = this.importData.player.volatiles[2]
    }
    if(this.importData.player.volatiles[3] == 1){
        this.sides[0].active[0].addVolatile("yawn")
    }
    if(this.importData.player.volatiles[4] == 1){
        this.sides[0].active[0].addVolatile("perishsong")
        this.sides[0].active[0].volatiles["perishsong"].duration = 3
    } else if(this.importData.player.volatiles[4] == 2){
        this.sides[0].active[0].addVolatile("perishsong")
        this.sides[0].active[0].volatiles["perishsong"].duration = 2
    } else if(this.importData.player.volatiles[4] == 3){
        this.sides[0].active[0].addVolatile("perishsong")
        this.sides[0].active[0].volatiles["perishsong"].duration = 1
    }
    if(this.importData.player.volatiles[5] == 1){
        this.sides[0].active[0].addVolatile("substitute")
    }
    if(this.importData.player.volatiles[6] == 1){
        this.sides[0].active[0].addVolatile("focusenergy")
    }
    if(this.importData.player.volatiles[7] == 1){
        this.sides[0].active[0].addVolatile("ingrain")
    }
    if (this.importData.player.volatiles[8] != 0){
        this.sides[0].active[0].lastMove = {id: this.importData.player.disable_move as ID} as ActiveMove
        this.sides[0].active[0].addVolatile('disable', this.sides[1].active[0])
        this.sides[0].active[0].volatiles["disable"].duration = this.importData.player.volatiles[8]
    }
    if (this.importData.player.volatiles[9] != 0){
        this.sides[0].active[0].lastMove = {id: this.importData.player.last_move as ID} as ActiveMove
        this.sides[0].active[0].addVolatile("encore")
    this.sides[0].active[0].volatiles["encore"].duration = this.importData.player.volatiles[9];
    }
    if (this.importData.player.volatiles[10] != 0){
        console.log(this.importData.player.volatiles[10])
        this.sides[0].addSlotCondition(this.sides[0].active[0], "futuremove", this.sides[1].active[0])
        this.sides[0].slotConditions[0]["futuremove"].duration = this.importData.player.volatiles[10];
        this.sides[0].slotConditions[0]["futuremove"].move = "futuresight";
        this.sides[0].slotConditions[0]["futuremove"].moveData = {
            id: 'futuresight',
            name: 'Future Sight',
            accuracy: 100,
            basePower: 120,
            category: 'Special',
            priority: 0,
            flags: {},
            ignoreImmunity: false,
            effectType: 'Move',
            isFutureMove: true,
            type: 'Psychic'
        };
    }
    if (this.importData.player.volatiles[11] != 0){
        this.sides[0].active[0].addVolatile("aquaring")
    }
    if (this.importData.player.volatiles[12] != 0){
        this.sides[0].active[0].addVolatile("attract", this.sides[1].active[0])
    }
    if (this.importData.player.volatiles[13] != 0){
        this.sides[0].active[0].addVolatile("torment")
    }



    if (this.importData.enemy.volatiles[1] == 1) {
        this.sides[1].active[0].addVolatile("confusion");
    }
    if (this.importData.enemy.volatiles[2] != 0) {
        this.sides[1].active[0].addVolatile("taunt");
        this.sides[1].active[0].volatiles["taunt"].duration =
            this.importData.enemy.volatiles[2];
    }
    if (this.importData.enemy.volatiles[3] == 1) {
        this.sides[1].active[0].addVolatile("yawn");
    }
    if (this.importData.enemy.volatiles[4] == 1) {
        this.sides[1].active[0].addVolatile("perishsong");
        this.sides[1].active[0].volatiles["perishsong"].duration = 3;
    } else if (this.importData.enemy.volatiles[4] == 2) {
        this.sides[1].active[0].addVolatile("perishsong");
        this.sides[1].active[0].volatiles["perishsong"].duration = 2;
    } else if (this.importData.enemy.volatiles[4] == 3) {
        this.sides[1].active[0].addVolatile("perishsong");
        this.sides[1].active[0].volatiles["perishsong"].duration = 1;
    }
    if (this.importData.enemy.volatiles[5] == 1) {
        this.sides[1].active[0].addVolatile("substitute");
    }
    if (this.importData.enemy.volatiles[6] == 1) {
        this.sides[1].active[0].addVolatile("focusenergy");
    }
    if (this.importData.enemy.volatiles[7] == 1) {
        this.sides[1].active[0].addVolatile("ingrain");
    }
    if (this.importData.enemy.volatiles[8] != 0) {
        this.sides[1].active[0].lastMove = {
            id: this.importData.enemy.disable_move as ID,
        } as ActiveMove;
        this.sides[1].active[0].addVolatile(
            "disable",
            this.sides[0].active[0]
        );
        this.sides[1].active[0].volatiles["disable"].duration =
            this.importData.enemy.volatiles[8];
    }
    if (this.importData.enemy.volatiles[9] != 0) {
        this.sides[1].active[0].lastMove = {
            id: this.importData.enemy.last_move as ID,
        } as ActiveMove;
        this.sides[1].active[0].addVolatile("encore");
        this.sides[1].active[0].volatiles["encore"].duration =
            this.importData.enemy.volatiles[9];
    }
    if (this.importData.enemy.volatiles[10] != 0) {
        this.sides[1].addSlotCondition(
            this.sides[1].active[0],
            "futuremove",
            this.sides[1].active[0]
        );
        this.sides[1].slotConditions[0]["futuremove"].duration =
            this.importData.enemy.volatiles[10];
        this.sides[1].slotConditions[0]["futuremove"].move =
            "futuresight";
        this.sides[1].slotConditions[0]["futuremove"].moveData = {
            id: "futuresight",
            name: "Future Sight",
            accuracy: 100,
            basePower: 120,
            category: "Special",
            priority: 0,
            flags: {},
            ignoreImmunity: false,
            effectType: "Move",
            isFutureMove: true,
            type: "Psychic",
        };
    }
    if (this.importData.enemy.volatiles[11] != 0) {
        this.sides[1].active[0].addVolatile("aquaring");
    }
    if (this.importData.enemy.volatiles[12] != 0) {
        this.sides[1].active[0].addVolatile(
            "attract",
            this.sides[0].active[0]
        );
    }
    if (this.importData.enemy.volatiles[13] != 0) {
        this.sides[1].active[0].addVolatile("torment");
    }

    // the variables if I want to set
    this.field.getWeather().duration - field.weatherState.duration
    this.sides[1].pokemon[0].status
    this.sides[0].pokemon[0].boosts
    this.sides[0].pokemon[0].hp
    this.sides[0].sideConditions.spikes
    this.sides[0].sideConditions.spikes.id
    this.sides[0].sideConditions.spikes.layers
    this.sides[0].sideConditions.stealthrock
    this.sides[1].sideConditions.stealthrock.id
    this.sides[0].sideConditions.stealthrock.layers
    this.sides[0].active
    this.sides[1].active

    Object.keys(this.sides[1].pokemon[0].volatiles)


inside Battle.runAction() under switch case "beforeTurn"

    // can't be in start for some reason (somehow interferes with switch logic)
    // sets hazards
    for (let i = 0; i < this.importData.player.hazards[0]; i++){
        this.sides[0].addSideCondition("spikes", "debug")
    }
    for (let i = 0; i < this.importData.player.hazards[1]; i++){
        this.sides[0].addSideCondition("toxicspikes", "debug")
    }
    for (let i = 0; i < this.importData.player.hazards[2]; i++){
        this.sides[0].addSideCondition("stealthrock", "debug")
    }
    if(this.importData.player.hazards[3] == 1){
        this.sides[0].addSideCondition("reflect", "debug")
    }
    if(this.importData.player.hazards[4] == 1){
        this.sides[0].addSideCondition("lightscreen", "debug")
    }
    if(this.importData.player.hazards[5] == 1){
        this.sides[0].addSideCondition("safeguard", "debug")
    }
    if(this.importData.player.hazards[6] == 1){
        this.sides[0].addSideCondition("mist", "debug")
    }
    if(this.importData.player.hazards[7] == 1){
        this.sides[0].addSideCondition("tailwind", "debug")
    }
    if(this.importData.player.hazards[8] == 1){
        this.sides[0].addSideCondition("luckychant", "debug")
    }
    for (let i = 0; i < this.importData.enemy.hazards[0]; i++){
        this.sides[1].addSideCondition("spikes", "debug")
    }
    for (let i = 0; i < this.importData.enemy.hazards[1]; i++){
        this.sides[1].addSideCondition("toxicspikes", "debug")
    }
    for (let i = 0; i < this.importData.enemy.hazards[2]; i++){
        this.sides[1].addSideCondition("stealthrock", "debug")
    }
    if(this.importData.enemy.hazards[3] == 1){
        this.sides[1].addSideCondition("reflect", "debug")
    }
    if(this.importData.enemy.hazards[4] == 1){
        this.sides[1].addSideCondition("lightscreen", "debug")
    }
    if(this.importData.enemy.hazards[5] == 1){
        this.sides[1].addSideCondition("safeguard", "debug")
    }
    if(this.importData.enemy.hazards[6] == 1){
        this.sides[1].addSideCondition("mist", "debug")
    }
    if(this.importData.enemy.hazards[7] == 1){
        this.sides[1].addSideCondition("tailwind", "debug")
    }
    if(this.importData.enemy.hazards[8] == 1){
        this.sides[1].addSideCondition("luckychant", "debug")
    }

pokemon-showdown

    // this saves the game log to a file
    let logFile = fs.createWriteStream("last_log.txt");
    battleStream.pipeTo(logFile, { noEnd: true });

battle-stream.ts

    // declare property initChunk for battle restart later
    initChunk: string | undefined;

    // ... 
    
    // add case "run-all" to simulate all possibilities
    case "run-all":
        for (let i = 1; i < 5; i++){
            for (let j = 1; j < 5; j++){
                console.log(`about to move ${i} ${j}`)
                this._writeLine("p1", `move ${i}`)
                this._writeLine("p2", `move ${j}`)
                console.log(this.battle?.log)
                console.log(this.battle?.turn)
                // export resulting data before "start"
                console.log("about to restart")
                this._write(this.initChunk as string)
            }
        }

        break;