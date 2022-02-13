/**
 * Battle Stream
 * Pokemon Showdown - http://pokemonshowdown.com/
 *
 * Supports interacting with a PS battle in Stream format.
 *
 * This format is VERY NOT FINALIZED, please do not use it directly yet.
 *
 * @license MIT
 */

import { Streams, Utils } from "../lib";
import { Teams } from "./teams";
import { Battle } from "./battle";
let fs = require("fs");
let msgpack = require("@msgpack/msgpack");

/**
 * Like string.split(delimiter), but only recognizes the first `limit`
 * delimiters (default 1).
 *
 * `"1 2 3 4".split(" ", 2) => ["1", "2"]`
 *
 * `Utils.splitFirst("1 2 3 4", " ", 1) => ["1", "2 3 4"]`
 *
 * Returns an array of length exactly limit + 1.
 */
function splitFirst(str: string, delimiter: string, limit = 1) {
	const splitStr: string[] = [];
	while (splitStr.length < limit) {
		const delimiterIndex = str.indexOf(delimiter);
		if (delimiterIndex >= 0) {
			splitStr.push(str.slice(0, delimiterIndex));
			str = str.slice(delimiterIndex + delimiter.length);
		} else {
			splitStr.push(str);
			str = "";
		}
	}
	splitStr.push(str);
	return splitStr;
}

export class BattleStream extends Streams.ObjectReadWriteStream<string> {
	debug: boolean;
	noCatch: boolean;
	replay: boolean | "spectator";
	keepAlive: boolean;
	battle: Battle | null;
	initChunk: string | undefined;
	jsonOutput: any;
	msgOutput: any;
	nnDebug = true;

	constructor(
		options: {
			debug?: boolean;
			noCatch?: boolean;
			keepAlive?: boolean;
			replay?: boolean | "spectator";
		} = {}
	) {
		super();
		this.debug = !!options.debug;
		this.noCatch = !!options.noCatch;
		this.replay = options.replay || false;
		this.keepAlive = !!options.keepAlive;
		this.battle = null;
	}

	_write(chunk: string) {
		if (this.noCatch) {
			this._writeLines(chunk);
		} else {
			try {
				this._writeLines(chunk);
			} catch (err: any) {
				this.pushError(err, true);
				return;
			}
		}

		// console.log(this.battle && this.battle.log);

		if (this.battle) this.battle.sendUpdates();
	}

	_writeLines(chunk: string) {
		this.initChunk = this.initChunk || chunk.slice(0, -11);
		for (const line of chunk.split("\n")) {
			if (line.startsWith(">")) {
				const [type, message] = splitFirst(line.slice(1), " ");

				this._writeLine(type, message);
			}
		}
	}

	pushMessage(type: string, data: string) {
		if (this.replay) {
			if (type === "update") {
				if (this.replay === "spectator") {
					this.push(
						data.replace(
							/\n\|split\|p[1234]\n(?:[^\n]*)\n([^\n]*)/g,
							"\n$1"
						)
					);
				} else {
					this.push(
						data.replace(
							/\n\|split\|p[1234]\n([^\n]*)\n(?:[^\n]*)/g,
							"\n$1"
						)
					);
				}
			}
			return;
		}
		this.push(`${type}\n${data}`);
	}

	getHazard(hazard: string, side: number) {
		if (this.battle?.sides[side].sideConditions[hazard] == null) {
			return 0;
		} else if (this.battle?.sides[side].sideConditions[hazard].duration) {
			return this.battle?.sides[side].sideConditions[hazard].duration;
		} else if (this.battle?.sides[side].sideConditions[hazard].layers) {
			return this.battle?.sides[side].sideConditions[hazard].layers;
		}
	}

	statusToArray(status: string) {
		if (status == "brn") {
			return [1, 0, 0, 0, 0, 0];
		} else if (status == "frz") {
			return [0, 1, 0, 0, 0, 0];
		} else if (status == "par") {
			return [0, 0, 1, 0, 0, 0];
		} else if (status == "psn") {
			return [0, 0, 0, 1, 0, 0];
		} else if (status == "tox") {
			return [0, 0, 0, 2, 0, 0];
		} else if (status == "slp") {
			return [0, 0, 0, 0, 1, 0];
		} else if (status == "fnt") {
			return [0, 0, 0, 0, 0, 1];
		} else {
			return [0, 0, 0, 0, 0, 0];
		}
	}

	getVolatiles(side: Side) {
		let volatiles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		for (let i = 0; i < side.pokemon.length; i++) {
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
			if (i < pokemon.length && pokemon[i].isActive) {
				boosts.push(
					...[
						pokemon[i].boosts.atk,
						pokemon[i].boosts.def,
						pokemon[i].boosts.spa,
						pokemon[i].boosts.spd,
						pokemon[i].boosts.spe,
						pokemon[i].boosts.accuracy,
						pokemon[i].boosts.evasion,
					]
				);
			}
		}
		return boosts;
	}

	baseStatsToArray(basestats: any) {
		return [
			basestats["hp"],
			basestats["atk"],
			basestats["def"],
			basestats["spa"],
			basestats["spd"],
			basestats["spe"],
		];
	}

	typesToArray(typesStr: any) {
		let types = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

		if (typesStr.includes("Bug")) types[0] = 1;
		if (typesStr.includes("Dark")) types[1] = 1;
		if (typesStr.includes("Dragon")) types[2] = 1;
		if (typesStr.includes("Electric")) types[3] = 1;
		if (typesStr.includes("Fighting")) types[4] = 1;
		if (typesStr.includes("Fire")) types[5] = 1;
		if (typesStr.includes("Flying")) types[6] = 1;
		if (typesStr.includes("Ghost")) types[7] = 1;
		if (typesStr.includes("Grass")) types[8] = 1;
		if (typesStr.includes("Ground")) types[9] = 1;
		if (typesStr.includes("Ice")) types[10] = 1;
		if (typesStr.includes("Normal")) types[11] = 1;
		if (typesStr.includes("Poison")) types[12] = 1;
		if (typesStr.includes("Psychic")) types[13] = 1;
		if (typesStr.includes("Rock")) types[14] = 1;
		if (typesStr.includes("Steel")) types[15] = 1;
		if (typesStr.includes("Water")) types[16] = 1;

		return types;
	}

	getArray(pokemon: Pokemon) {
		let hp = Math.round((pokemon.hp / pokemon.maxhp) * 100);
		let basestats = this.baseStatsToArray(pokemon.baseStoredStats);
		let types = this.typesToArray(pokemon["types"]);
		let status = this.statusToArray(pokemon.status);

		// [0, *[0, 0, 0, 0, 0, 0], *[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], *[0, 0, 0, 0, 0]]
		// [100, 75, 75, 75, 130, 95, 130, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0]

		// console.log(1, basestats.length, types.length, status.length);

		return [hp, ...basestats, ...types, ...status];
	}

	getActive(side: number) {
		for (
			let i = 0;
			i < (this.battle as Battle).sides[side].pokemon.length;
			i++
		) {
			if (
				(this.battle as Battle).startTeam[side][i] ==
				(this.battle as Battle).sides[side].active[0].species.name
			) {
				return i;
			}
		}
		return 500;
	}

	getEncoredMove(side: number) {
		if ((this.battle as Battle).sides[side].active[0].volatiles["encore"]) {
			return (this.battle as Battle).sides[side].active[0].volatiles[
				"encore"
			].move;
		} else {
			return "N/A";
		}
	}

	getDisabledMove(side: number) {
		if ((this.battle as Battle).sides[side].active[0].volatiles["disable"]) {
			return (this.battle as Battle).sides[side].active[0].volatiles[
				"disable"
			].move;
		} else {
			return "N/A";
		}
	}

	getJson(activePokemonName: string | undefined) {
		let weatherStr = this.battle?.field.weather;
		let weather;

		if (weatherStr == "sunnyday") {
			weather = [1, 0, 0, 0];
		} else if (weatherStr == "RainDance") {
			weather = [0, 1, 0, 0];
		} else if (weatherStr == "Sandstorm") {
			weather = [0, 0, 1, 0];
		} else if (weatherStr == "hail") {
			weather = [0, 0, 0, 1];
		} else {
			weather = [0, 0, 0, 0];
		}

		let hazardsP1 = [
			this.getHazard("spikes", 0),
			this.getHazard("toxicspikes", 0),
			this.getHazard("stealthrock", 0),
			this.getHazard("reflect", 0),
			this.getHazard("lightscreen", 0),
			this.getHazard("safeguard", 0),
			this.getHazard("mist", 0),
			this.getHazard("tailwind", 0),
			this.getHazard("luckychant", 0),
		];
		let hazardsP2 = [
			this.getHazard("spikes", 1),
			this.getHazard("toxicspikes", 1),
			this.getHazard("stealthrock", 1),
			this.getHazard("reflect", 1),
			this.getHazard("lightscreen", 1),
			this.getHazard("safeguard", 1),
			this.getHazard("mist", 1),
			this.getHazard("tailwind", 1),
			this.getHazard("luckychant", 1),
		];

		let activeP1 = [];
		let activeP2 = [];
		let benchP1 = [];
		let benchP2 = [];

		for (let i = 0; i < 6; i++) {
			if (i < (this.battle?.sides[0].pokemon.length as number)) {
				if (!this.battle?.sides[0].pokemon[i].isActive) {
					benchP1.push(
						...this.getArray(this.battle?.sides[0].pokemon[i] as Pokemon)
					);
				} else {
					activeP1.push(
						...this.getArray(this.battle?.sides[0].pokemon[i] as Pokemon)
					);
				}
			} else {
				benchP1.push(
					...[
						0,
						...[0, 0, 0, 0, 0, 0],
						...[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
						...[0, 0, 0, 0, 0, 0],
					]
				);
			}

			if (i < (this.battle?.sides[1].pokemon.length as number)) {
				if (!this.battle?.sides[1].pokemon[i].isActive) {
					benchP2.push(
						...this.getArray(this.battle?.sides[1].pokemon[i] as Pokemon)
					);
				} else {
					activeP2.push(
						...this.getArray(this.battle?.sides[1].pokemon[i] as Pokemon)
					);
				}
			} else {
				benchP2.push(
					...[
						0,
						...[0, 0, 0, 0, 0, 0],
						...[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
						...[0, 0, 0, 0, 0, 0],
					]
				);
			}
		}

		let volatilesP1 = this.getVolatiles(this.battle?.sides[0] as Side);
		let volatilesP2 = this.getVolatiles(this.battle?.sides[1] as Side);

		let boostsP1 = this.getBoosts(this.battle?.sides[0].pokemon as Pokemon[]);
		let boostsP2 = this.getBoosts(this.battle?.sides[1].pokemon as Pokemon[]);

		// console.log(
		// 	1,
		// 	weather.length,
		// 	hazardsP1.length,
		// 	hazardsP2.length,
		// 	volatilesP1.length,
		// 	volatilesP2.length,
		// 	boostsP1.length,
		// 	boostsP2.length,
		// 	activeP1.length,
		// 	activeP2.length,
		// 	benchP1.length,
		// 	benchP2.length
		// );

		let returnVal = [
			[
				this.battle?.field.weatherState.duration,
				...weather,
				...hazardsP1,
				...hazardsP2,
				...volatilesP1,
				...volatilesP2,
				...boostsP1,
				...boostsP2,
				...activeP1,
				...benchP1,
				...activeP2,
				...benchP2,
			],
			activePokemonName || "not switch",
			this.getActive(0),
			this.getActive(1),
			this.getEncoredMove(0),
			this.getEncoredMove(1),
			this.getDisabledMove(0),
			this.getDisabledMove(1),
		];

		return returnVal;
	}

	getHazardDebug(hazard: string, side: number) {
		if (this.battle?.sides[0].sideConditions[hazard] == null) {
			return 0;
		} else if (this.battle?.sides[0].sideConditions[hazard].duration) {
			return this.battle?.sides[0].sideConditions[hazard].duration;
		} else if (this.battle?.sides[0].sideConditions[hazard].layers) {
			return this.battle?.sides[0].sideConditions[hazard].layers;
		}
	}

	getVolatilesDebug(side: Side) {
		let volatiles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		for (let i = 0; i < 6; i++) {
			if (i < side.pokemon.length) {
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
					} else if (
						side.pokemon[i].volatiles["perishsong"].duration == 2
					) {
						volatiles[4] = 2;
					} else if (
						side.pokemon[i].volatiles["perishsong"].duration == 1
					) {
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
		}
		return volatiles;
	}

	getBoostsDebug(pokemon: Pokemon[]) {
		let boosts = [];
		for (let i = 0; i < 6; i++) {
			if (i < pokemon.length) {
				boosts[i] = pokemon[i].boosts;
			} else {
				boosts[i] = {};
			}
		}
		return boosts;
	}

	getHPDebug(pokemon: Pokemon[]) {
		let hp = [];
		for (let i = 0; i < 6; i++) {
			if (i < pokemon.length) {
				hp[i] = Math.round((pokemon[i].hp / pokemon[i].maxhp) * 100);
			} else {
				hp[i] = "N/A";
			}
		}
		return hp;
	}

	getStatsDebug(pokemon: Pokemon[]) {
		let stats = [];
		for (let i = 0; i < 6; i++) {
			if (i < pokemon.length) {
				stats[i] = this.baseStatsToArray(pokemon[i].species.baseStats);
			} else {
				stats[i] = {};
			}
		}
		return stats;
	}

	getTypesDebug(pokemon: Pokemon[]) {
		let types = [];
		for (let i = 0; i < 6; i++) {
			if (i < pokemon.length) {
				types[i] = pokemon[i].types;
			} else {
				types[i] = [];
			}
		}
		return types;
	}

	getJsonDebug() {
		let weather = this.battle?.field.weather;
		let hazardsP1 = [
			this.getHazardDebug("spikes", 0),
			this.getHazardDebug("toxicspikes", 0),
			this.getHazardDebug("stealthrock", 0),
			this.getHazardDebug("reflect", 0),
			this.getHazardDebug("lightscreen", 0),
			this.getHazardDebug("safeguard", 0),
			this.getHazardDebug("mist", 0),
			this.getHazardDebug("tailwind", 0),
			this.getHazardDebug("luckychant", 0),
		];
		let hazardsP2 = [
			this.getHazardDebug("spikes", 1),
			this.getHazardDebug("toxicspikes", 1),
			this.getHazardDebug("stealthrock", 1),
			this.getHazardDebug("reflect", 1),
			this.getHazardDebug("lightscreen", 1),
			this.getHazardDebug("safeguard", 1),
			this.getHazardDebug("mist", 1),
			this.getHazardDebug("tailwind", 1),
			this.getHazardDebug("luckychant", 1),
		];
		let statusP1 = [];
		let statusP2 = [];

		for (let i = 0; i < 6; i++) {
			if (i < (this.battle?.sides[0].pokemon as Pokemon[]).length) {
				statusP1.push(
					this.statusToArray(
						this.battle?.sides[0].pokemon[i].status as string
					)
				);
			} else {
				statusP1.push("N/A");
			}

			if (i < (this.battle?.sides[1].pokemon as Pokemon[]).length) {
				statusP2.push(
					this.statusToArray(
						this.battle?.sides[1].pokemon[i].status as string
					)
				);
			} else {
				statusP2.push("N/A");
			}
		}

		let volatilesP1 = this.getVolatilesDebug(this.battle?.sides[0] as Side);
		let volatilesP2 = this.getVolatilesDebug(this.battle?.sides[1] as Side);

		let boostsP1 = this.getBoosts(this.battle?.sides[0].pokemon as Pokemon[]);
		let boostsP2 = this.getBoosts(this.battle?.sides[1].pokemon as Pokemon[]);

		let hpP1 = this.getHPDebug(this.battle?.sides[0].pokemon as Pokemon[]);
		let hpP2 = this.getHPDebug(this.battle?.sides[1].pokemon as Pokemon[]);

		let statsP1 = this.getStatsDebug(
			this.battle?.sides[0].pokemon as Pokemon[]
		);
		let statsP2 = this.getStatsDebug(
			this.battle?.sides[1].pokemon as Pokemon[]
		);

		let typesP1 = this.getTypesDebug(
			this.battle?.sides[0].pokemon as Pokemon[]
		);
		let typesP2 = this.getTypesDebug(
			this.battle?.sides[1].pokemon as Pokemon[]
		);

		return {
			weather,
			hazardsP1,
			hazardsP2,
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
			log: this.battle?.log,
			P1Active: this.getActive(0),
			P2Active: this.getActive(1),
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

	_writeLine(type: string, message: string) {
		switch (type) {
			case "start":
				const options = JSON.parse(message);
				options.send = (t: string, data: any) => {
					if (Array.isArray(data)) data = data.join("\n");
					this.pushMessage(t, data);
					if (t === "end" && !this.keepAlive) this.pushEnd();
				};
				if (this.debug) options.debug = true;
				this.battle = new Battle(options);
				break;
			case "player":
				const [slot, optionsText] = splitFirst(message, " ");
				this.battle!.setPlayer(slot as SideID, JSON.parse(optionsText));
				break;
			case "p1":
			case "p2":
			case "p3":
			case "p4":
				if (message === "undo") {
					this.battle!.undoChoice(type);
				} else {
					this.battle!.choose(type, message);
				}
				break;
			case "run-all":
				for (let i = 1; i < 11; i++) {
					for (let j = 1; j < 11; j++) {
						this.playFromAction(i, j);

						this.battle?.sendUpdates();

						let activeNickname = undefined;

						if (i > 4) {
							activeNickname = this.battle?.sides[0].active[0].name;
						}

						let thisOutput = [];
						let thisOutputDebug = [];

						if (
							this.battle?.sides[0].choice.forcedSwitchesLeft == 0 &&
							this.battle?.sides[1].choice.forcedSwitchesLeft == 0 &&
							this.battle?.sides[0].choice.error === "" &&
							this.battle?.sides[1].choice.error === ""
						) {
							// if there's no errors or forced switches
							thisOutput.push(this.getJson(activeNickname));

							if (this.nnDebug) {
								thisOutputDebug.push(this.getJsonDebug());
							}
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
									if (this.battle?.sides[0].choice.error === "") {
										thisOutput.push(this.getJson(activeNickname));
										if (this.nnDebug) {
											thisOutputDebug.push(this.getJsonDebug());
										}
									}

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
								if (this.battle?.sides[0].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p1 switch 2`);
								this.playFromAction(i, j);
								this._writeLine("p1", "switch 2");
								this.battle?.sendUpdates();
								if (this.battle?.sides[0].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p1 switch 3`);
								this.playFromAction(i, j);
								this._writeLine("p1", "switch 3");
								this.battle?.sendUpdates();
								if (this.battle?.sides[0].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p1 switch 4`);
								this.playFromAction(i, j);
								this._writeLine("p1", "switch 4");
								this.battle?.sendUpdates();
								if (this.battle?.sides[0].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p1 switch 5`);
								this.playFromAction(i, j);
								this._writeLine("p1", "switch 5");
								this.battle?.sendUpdates();
								if (this.battle?.sides[0].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p1 switch 6`);
								this.playFromAction(i, j);
								this._writeLine("p1", "switch 6");
								this.battle?.sendUpdates();
								if (this.battle?.sides[0].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
							}

							if (
								!!this.battle?.sides[1].choice.forcedSwitchesLeft &&
								this.battle?.sides[1].choice.forcedSwitchesLeft > 0
							) {
								this._writeLine("p2", "switch 1");
								this.battle?.sendUpdates();
								if (this.battle?.sides[1].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p2 switch 2`);
								this.playFromAction(i, j);
								this._writeLine("p2", "switch 2");
								this.battle?.sendUpdates();
								if (this.battle?.sides[1].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p2 switch 3`);
								this.playFromAction(i, j);
								this._writeLine("p2", "switch 3");
								this.battle?.sendUpdates();
								if (this.battle?.sides[1].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p2 switch 4`);
								this.playFromAction(i, j);
								this._writeLine("p2", "switch 4");
								this.battle?.sendUpdates();
								if (this.battle?.sides[1].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p2 switch 5`);
								this.playFromAction(i, j);
								this._writeLine("p2", "switch 5");
								this.battle?.sendUpdates();
								if (this.battle?.sides[1].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
								this._write(this.initChunk as string);

								// this.battle?.send("", `${i} ${j}: p2 switch 6`);
								this.playFromAction(i, j);
								this._writeLine("p2", "switch 6");
								this.battle?.sendUpdates();
								if (this.battle?.sides[1].choice.error === "") {
									thisOutput.push(this.getJson(activeNickname));
									if (this.nnDebug) {
										thisOutputDebug.push(this.getJsonDebug());
									}
								}
							}
						}

						if (this.nnDebug) {
							this.jsonOutput = this.jsonOutput || [];
							this.jsonOutput[j - 1] = this.jsonOutput[j - 1] || [];
							this.jsonOutput[j - 1][i - 1] = thisOutputDebug;
						}
						this.msgOutput = this.msgOutput || [];
						this.msgOutput[j - 1] = this.msgOutput[j - 1] || [];
						this.msgOutput[j - 1][i - 1] = thisOutput;

						if (i !== 10 || j !== 10)
							this._write(this.initChunk as string);
					}
				}

				fs.writeFileSync(
					"./battle_ai/state_files/battleStatesFromShowdown.txt",
					Buffer.from(msgpack.encode(this.msgOutput))
				);

				// this write file is purely for debugging
				if (this.nnDebug) {
					fs.writeFileSync(
						"./battle_ai/state_files/battleStatesFromShowdown.json",
						JSON.stringify({
							inputState: this.battle?.importData,
							outputStates: this.jsonOutput,
						})
					);
				}

				console.log("Saved Showdown Simulation");
				return true;
			// break;
			case "forcewin":
			case "forcetie":
				this.battle!.win(type === "forcewin" ? (message as SideID) : null);
				if (message) {
					this.battle!.inputLog.push(`>forcewin ${message}`);
				} else {
					this.battle!.inputLog.push(`>forcetie`);
				}
				break;
			case "forcelose":
				this.battle!.lose(message as SideID);
				this.battle!.inputLog.push(`>forcelose ${message}`);
				break;
			case "reseed":
				const seed = message
					? (message.split(",").map(Number) as PRNGSeed)
					: null;
				this.battle!.resetRNG(seed);
				// could go inside resetRNG, but this makes using it in `eval` slightly less buggy
				this.battle!.inputLog.push(
					`>reseed ${this.battle!.prng.seed.join(",")}`
				);
				break;
			case "tiebreak":
				this.battle!.tiebreak();
				break;
			case "chat-inputlogonly":
				this.battle!.inputLog.push(`>chat ${message}`);
				break;
			case "chat":
				this.battle!.inputLog.push(`>chat ${message}`);
				this.battle!.add("chat", `${message}`);
				break;
			case "eval":
				const battle = this.battle!;

				// n.b. this will usually but not always work - if you eval code that also affects the inputLog,
				// replaying the inputlog would double-play the change.
				battle.inputLog.push(`>${type} ${message}`);

				message = message.replace(/\f/g, "\n");
				battle.add("", ">>> " + message.replace(/\n/g, "\n||"));
				try {
					/* eslint-disable no-eval, @typescript-eslint/no-unused-vars */
					const p1 = battle.sides[0];
					const p2 = battle.sides[1];
					const p3 = battle.sides[2];
					const p4 = battle.sides[3];
					const p1active = p1?.active[0];
					const p2active = p2?.active[0];
					const p3active = p3?.active[0];
					const p4active = p4?.active[0];
					const toID = battle.toID;
					const player = (input: string) => {
						input = toID(input);
						if (/^p[1-9]$/.test(input))
							return battle.sides[parseInt(input.slice(1)) - 1];
						if (/^[1-9]$/.test(input))
							return battle.sides[parseInt(input) - 1];
						for (const side of battle.sides) {
							if (toID(side.name) === input) return side;
						}
						return null;
					};
					const pokemon = (side: string | Side, input: string) => {
						if (typeof side === "string") side = player(side)!;

						input = toID(input);
						if (/^[1-9]$/.test(input))
							return side.pokemon[parseInt(input) - 1];
						return side.pokemon.find(
							(p) => p.baseSpecies.id === input || p.species.id === input
						);
					};
					let result = eval(message);
					/* eslint-enable no-eval, @typescript-eslint/no-unused-vars */

					if (result?.then) {
						result.then(
							(unwrappedResult: any) => {
								unwrappedResult = Utils.visualize(unwrappedResult);
								battle.add("", "Promise -> " + unwrappedResult);
								battle.sendUpdates();
							},
							(error: Error) => {
								battle.add("", "<<< error: " + error.message);
								battle.sendUpdates();
							}
						);
					} else {
						result = Utils.visualize(result);
						result = result.replace(/\n/g, "\n||");
						battle.add("", "<<< " + result);
					}
				} catch (e: any) {
					battle.add("", "<<< error: " + e.message);
				}
				break;
			case "requestlog":
				this.push(`requesteddata\n${this.battle!.inputLog.join("\n")}`);
				break;
			case "requestteam":
				message = message.trim();
				const slotNum = parseInt(message.slice(1)) - 1;
				if (isNaN(slotNum) || slotNum < 0) {
					throw new Error(
						`Team requested for slot ${message}, but that slot does not exist.`
					);
				}
				const side = this.battle!.sides[slotNum];
				const team = Teams.pack(side.team);
				this.push(`requesteddata\n${team}`);
				break;
			case "version":
			case "version-origin":
				break;
			default:
				throw new Error(`Unrecognized command ">${type} ${message}"`);
		}
	}

	_writeEnd() {
		// if battle already ended, we don't need to pushEnd.
		if (!this.atEOF) this.pushEnd();
		this._destroy();
	}

	_destroy() {
		if (this.battle) this.battle.destroy();
	}
}

/**
 * Splits a BattleStream into omniscient, spectator, p1, p2, p3 and p4
 * streams, for ease of consumption.
 */
export function getPlayerStreams(stream: BattleStream) {
	const streams = {
		omniscient: new Streams.ObjectReadWriteStream({
			write(data: string) {
				void stream.write(data);
			},
			writeEnd() {
				return stream.writeEnd();
			},
		}),
		spectator: new Streams.ObjectReadStream<string>({
			read() {},
		}),
		p1: new Streams.ObjectReadWriteStream({
			write(data: string) {
				void stream.write(data.replace(/(^|\n)/g, `$1>p1 `));
			},
		}),
		p2: new Streams.ObjectReadWriteStream({
			write(data: string) {
				void stream.write(data.replace(/(^|\n)/g, `$1>p2 `));
			},
		}),
		p3: new Streams.ObjectReadWriteStream({
			write(data: string) {
				void stream.write(data.replace(/(^|\n)/g, `$1>p3 `));
			},
		}),
		p4: new Streams.ObjectReadWriteStream({
			write(data: string) {
				void stream.write(data.replace(/(^|\n)/g, `$1>p4 `));
			},
		}),
	};
	(async () => {
		for await (const chunk of stream) {
			const [type, data] = splitFirst(chunk, `\n`);
			switch (type) {
				case "update":
					streams.omniscient.push(
						Battle.extractUpdateForSide(data, "omniscient")
					);
					streams.spectator.push(
						Battle.extractUpdateForSide(data, "spectator")
					);
					streams.p1.push(Battle.extractUpdateForSide(data, "p1"));
					streams.p2.push(Battle.extractUpdateForSide(data, "p2"));
					streams.p3.push(Battle.extractUpdateForSide(data, "p3"));
					streams.p4.push(Battle.extractUpdateForSide(data, "p4"));
					break;
				case "sideupdate":
					const [side, sideData] = splitFirst(data, `\n`);
					streams[side as SideID].push(sideData);
					break;
				case "end":
					// ignore
					break;
			}
		}
		for (const s of Object.values(streams)) {
			s.pushEnd();
		}
	})().catch((err) => {
		for (const s of Object.values(streams)) {
			s.pushError(err, true);
		}
	});
	return streams;
}

export abstract class BattlePlayer {
	readonly stream: Streams.ObjectReadWriteStream<string>;
	readonly log: string[];
	readonly debug: boolean;

	constructor(
		playerStream: Streams.ObjectReadWriteStream<string>,
		debug = false
	) {
		this.stream = playerStream;
		this.log = [];
		this.debug = debug;
	}

	async start() {
		for await (const chunk of this.stream) {
			this.receive(chunk);
		}
	}

	receive(chunk: string) {
		for (const line of chunk.split("\n")) {
			this.receiveLine(line);
		}
	}

	receiveLine(line: string) {
		if (this.debug) console.log(line);
		if (!line.startsWith("|")) return;
		const [cmd, rest] = splitFirst(line.slice(1), "|");
		if (cmd === "request") return this.receiveRequest(JSON.parse(rest));
		if (cmd === "error") return this.receiveError(new Error(rest));
		this.log.push(line);
	}

	abstract receiveRequest(request: AnyObject): void;

	receiveError(error: Error) {
		throw error;
	}

	choose(choice: string) {
		void this.stream.write(choice);
	}
}

export class BattleTextStream extends Streams.ReadWriteStream {
	readonly battleStream: BattleStream;
	currentMessage: string;

	constructor(options: { debug?: boolean }) {
		super();
		this.battleStream = new BattleStream(options);
		this.currentMessage = "";
		void this._listen();
	}

	async _listen() {
		for await (let message of this.battleStream) {
			if (!message.endsWith("\n")) message += "\n";
			this.push(message + "\n");
		}
		this.pushEnd();
	}

	_write(message: string | Buffer) {
		this.currentMessage += "" + message;
		const index = this.currentMessage.lastIndexOf("\n");
		if (index >= 0) {
			void this.battleStream.write(this.currentMessage.slice(0, index));
			this.currentMessage = this.currentMessage.slice(index + 1);
		}
	}

	_writeEnd() {
		return this.battleStream.writeEnd();
	}
}
