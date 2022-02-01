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

    // add new helper functions
    getHazard(hazard: string) {
    	if (this.battle?.sides[0].sideConditions[hazard] == null) {
    		return 0;
    	} else if (this.battle?.sides[0].sideConditions[hazard].duration) {
    		return this.battle?.sides[0].sideConditions[hazard].duration;
    	} else if (this.battle?.sides[0].sideConditions[hazard].layers) {
    		return this.battle?.sides[0].sideConditions[hazard].layers;
    	}
    }

    getVolatiles(side: Side) {
    	let volatiles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    	for (let i = 0; i < 6; i++) {
    		// console.log(Object.keys(side.pokemon[i].volatiles));
    		if (side.pokemon[i].volatiles["leechseed"]) {
    			volatiles[0] = 1;
    		}
    		if (side.pokemon[i].volatiles["confusion"]) {
    			volatiles[1] = side.pokemon[i].volatiles["confusion"].duration;
    		}
    		if (side.pokemon[i].volatiles["taunt"]) {
    			volatiles[2] = side.pokemon[i].volatiles["taunt"].duration;
    		}
    		if (side.pokemon[i].volatiles["yawn"]) {
    			volatiles[3] = 1;
    		}
    		if (side.pokemon[i].volatiles["perishsong"]) {
    			if (side.pokemon[i].volatiles["perishsong"].duration == 3) {
    				volatiles[4] = 1;
    			} else if (side.pokemon[i].volatiles["perishsong"].duration == 2) {
    				volatiles[4] = 2;
    			} else if (side.pokemon[i].volatiles["perishsong"].duration == 1) {
    				volatiles[4] = 3;
    			}
    		}
    		if (side.pokemon[i].volatiles["substitute"]) {
    			volatiles[5] = 1;
    		}
    		if (side.pokemon[i].volatiles["focusenergy"]) {
    			volatiles[6] = 1;
    		}
    		if (side.pokemon[i].volatiles["ingrain"]) {
    			volatiles[7] = 1;
    		}
    		if (side.pokemon[i].volatiles["disable"]) {
    			volatiles[8] = side.pokemon[i].volatiles["disable"].duration;
    		}
    		if (side.pokemon[i].volatiles["encore"]) {
    			volatiles[9] = side.pokemon[i].volatiles["encore"].duration;
    		}
    		if (side.slotConditions[0]["futuremove"]) {
    			volatiles[10] = side.slotConditions[0]["futuremove"].duration;
    		}
    		if (side.pokemon[i].volatiles["aquaring"]) {
    			volatiles[11] = 1;
    		}
    		if (side.pokemon[i].volatiles["attract"]) {
    			volatiles[12] = 1;
    		}
    		if (side.pokemon[i].volatiles["torment"]) {
    			volatiles[13] = 1;
    		}
    	}
    	return volatiles;
    }

    getBoosts(pokemon: Pokemon[]) {
    	let boosts = [];
    	for (let i = 0; i < 6; i++) {
    		boosts[i] = pokemon[i].boosts;
    	}
    	return boosts;
    }

    getHP(pokemon: Pokemon[]) {
    	let hp = [];
    	for (let i = 0; i < 6; i++) {
    		hp[i] = Math.round((pokemon[i].hp / pokemon[i].maxhp) * 100);
    	}
    	return hp;
    }

    getStats(pokemon: Pokemon[]) {
    	let stats = [];
    	for (let i = 0; i < 6; i++) {
    		stats[i] = pokemon[i].storedStats;
    	}
    	return stats;
    }

    getTypes(pokemon: Pokemon[]) {
    	let types = [];
    	for (let i = 0; i < 6; i++) {
    		types[i] = pokemon[i].types;
    	}
    	return types;
    }

    getJson() {
    	let weather = this.battle?.field.weather;
    	let hazards = [
    		this.getHazard("spikes"),
    		this.getHazard("toxicspikes"),
    		this.getHazard("stealthrock"),
    		this.getHazard("reflect"),
    		this.getHazard("lightscreen"),
    		this.getHazard("safeguard"),
    		this.getHazard("mist"),
    		this.getHazard("tailwind"),
    		this.getHazard("luckychant"),
    	];
    	let statusP1 = [];
    	let statusP2 = [];

    	for (let i = 0; i < 6; i++) {
    		statusP1.push(this.battle?.sides[0].pokemon[i].status);
    		statusP2.push(this.battle?.sides[1].pokemon[i].status);
    	}

    	let volatilesP1 = this.getVolatiles(this.battle?.sides[0] as Side);
    	let volatilesP2 = this.getVolatiles(this.battle?.sides[1] as Side);

    	let boostsP1 = this.getBoosts(this.battle?.sides[0].pokemon as Pokemon[]);
    	let boostsP2 = this.getBoosts(this.battle?.sides[1].pokemon as Pokemon[]);

    	let hpP1 = this.getHP(this.battle?.sides[0].pokemon as Pokemon[]);
    	let hpP2 = this.getHP(this.battle?.sides[1].pokemon as Pokemon[]);

    	let statsP1 = this.getStats(this.battle?.sides[0].pokemon as Pokemon[]);
    	let statsP2 = this.getStats(this.battle?.sides[1].pokemon as Pokemon[]);

    	let typesP1 = this.getTypes(this.battle?.sides[0].pokemon as Pokemon[]);
    	let typesP2 = this.getTypes(this.battle?.sides[1].pokemon as Pokemon[]);

    	return {
    		weather,
    		hazards,
    		statusP1,
    		statusP2,
    		volatilesP1,
    		volatilesP2,
    		boostsP1,
    		boostsP2,
    		hpP1,
    		hpP2,
    		statsP1,
    		statsP2,
    		typesP1,
    		typesP2,
    	};
    }

    playFromAction(i: number, j: number) {
    	if (i < 5) {
    		this._writeLine("p1", `move ${i}`);
    	} else {
    		this._writeLine("p1", `switch ${i - 4}`);
    	}
    	if (j < 5) {
    		this._writeLine("p2", `move ${j}`);
    	} else {
    		this._writeLine("p2", `switch ${j - 4}`);
    	}
    }

    // add case "run-all" to simulate all possibilities
    case "run-all":
        for (let i = 1; i < 11; i++) {
            for (let j = 1; j < 11; j++) {

                this.playFromAction(i, j);
                this.battle?.sendUpdates();

                let thisOutput = [];

                if (
                    this.battle?.sides[0].choice.forcedSwitchesLeft == 0 &&
                    this.battle?.sides[1].choice.forcedSwitchesLeft == 0 &&
                    this.battle?.sides[0].choice.error === "" &&
                    this.battle?.sides[1].choice.error === ""
                ) {
                    // if there's no errors or forced switches
                    thisOutput.push(this.getJson());
                }

                if (
                    this.battle?.sides[0].choice.forcedSwitchesLeft !== 0 &&
                    this.battle?.sides[1].choice.forcedSwitchesLeft !== 0
                ) {
                    for (let k = 5; k < 11; k++) {
                        for (let l = 5; l < 11; l++) {
                            if (k !== 5 || l !== 5) {
                                this.playFromAction(k, j);
                            }

                            this._writeLine("p1", `switch ${k - 4}`);
                            this._writeLine("p2", `switch ${l - 4}`);
                            this.battle?.sendUpdates();
                            if (this.battle?.sides[0].choice.error === "")
                                thisOutput.push(this.getJson());

                            if (k !== 10 || l !== 10) {
                                this._write(this.initChunk as string);
                            }
                        }
                    }
                } else {
                    if (
                        !!this.battle?.sides[0].choice.forcedSwitchesLeft &&
                        this.battle?.sides[0].choice.forcedSwitchesLeft > 0
                    ) {
                        this._writeLine("p1", "switch 1");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[0].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p1 switch 2`);
                        this.playFromAction(i, j);
                        this._writeLine("p1", "switch 2");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[0].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p1 switch 3`);
                        this.playFromAction(i, j);
                        this._writeLine("p1", "switch 3");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[0].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p1 switch 4`);
                        this.playFromAction(i, j);
                        this._writeLine("p1", "switch 4");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[0].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p1 switch 5`);
                        this.playFromAction(i, j);
                        this._writeLine("p1", "switch 5");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[0].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p1 switch 6`);
                        this.playFromAction(i, j);
                        this._writeLine("p1", "switch 6");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[0].choice.error === "")
                            thisOutput.push(this.getJson());
                    }

                    if (
                        !!this.battle?.sides[1].choice.forcedSwitchesLeft &&
                        this.battle?.sides[1].choice.forcedSwitchesLeft > 0
                    ) {
                        this._writeLine("p2", "switch 1");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[1].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p2 switch 2`);
                        this.playFromAction(i, j);
                        this._writeLine("p2", "switch 2");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[1].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p2 switch 3`);
                        this.playFromAction(i, j);
                        this._writeLine("p2", "switch 3");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[1].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p2 switch 4`);
                        this.playFromAction(i, j);
                        this._writeLine("p2", "switch 4");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[1].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p2 switch 5`);
                        this.playFromAction(i, j);
                        this._writeLine("p2", "switch 5");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[1].choice.error === "")
                            thisOutput.push(this.getJson());
                        this._write(this.initChunk as string);

                        // this.battle?.send("", `${i} ${j}: p2 switch 6`);
                        this.playFromAction(i, j);
                        this._writeLine("p2", "switch 6");
                        this.battle?.sendUpdates();
                        if (this.battle?.sides[1].choice.error === "")
                            thisOutput.push(this.getJson());
                    }
                }

                this.jsonOutput = this.jsonOutput || [];
                this.jsonOutput[j - 1] = this.jsonOutput[j - 1] || [];
                this.jsonOutput[j - 1][i - 1] = thisOutput;

                if (i !== 10 || j !== 10)
                    this._write(this.initChunk as string);
            }
        }
        fs.writeFileSync(
            "./battle_ai/state_files/battleStatesFromShowdown.json",
            JSON.stringify(this.jsonOutput)
        );
        // recall that battle.possibleSwitches exists when doing switches
        break;
