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
		// console.log(this.battle && this.battle.log);

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

	getHazard(hazard: string){
		if (this.battle?.sides[0].sideConditions[hazard] == null){
			return 0;
		} else if (this.battle?.sides[0].sideConditions[hazard].duration){
			return this.battle?.sides[0].sideConditions[hazard].duration
		} else if (this.battle?.sides[0].sideConditions[hazard].layers){
			return this.battle?.sides[0].sideConditions[hazard].layers
		}
	}

	getJson() {
		let weather = this.battle?.field.weather;
		let hazards = [ this.getHazard("spikes"), this.getHazard("toxicspikes"), 
			this.getHazard("stealthrock"), this.getHazard("reflect"), this.getHazard("lightscreen"), 
			this.getHazard("safeguard"), this.getHazard("mist"), this.getHazard("tailwind"), 
			this.getHazard("luckychant") ]
		let statusP1 = [];
		let statusP2 = [];

		for (let i = 0; i < 6; i++){
			statusP1.push(this.battle?.sides[0].pokemon[i].status)
			statusP2.push(this.battle?.sides[1].pokemon[i].status)
		}

		console.log(statusP1, statusP2)
		
		return {
			weather,
			hazards,
			statusP1,
			statusP2
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
				// console.log(
				// 	"player call, battle: ",
				// 	this.battle && this.battle.log
				// );
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
