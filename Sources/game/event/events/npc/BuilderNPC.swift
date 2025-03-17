import Foundation

struct BuilderNPC: TalkableNPC {
	static func talk(npc: NPC) async {
		if !npc.hasTalkedToBefore {
			await NPC.setTalkedTo {
				await MessageBox.message("Hello, I'm \(npc.name)! I can help you with building. Let's start! Go get all of the materials you need and then we can build your castle!", speaker: .npc(name: npc.name, job: npc.job))
				await Game.shared.player.setCanBuild(false)
				await Game.shared.addKingdomData(.gettingStuffToBuildCastle, npcInKindom: npc.id)
			}
		} else {
			let kingdom = await Game.shared.getKingdom(for: npc)
			if let kingdom {
				if !kingdom.hasCastle {
					await buildCastle(npc: npc, kingdom: kingdom)
				} else {
					await talkNormally(kingdom: kingdom, npc)
				}
			} else {
				await MessageBox.message("I don't know what to do (2)", speaker: .npc(name: npc.name, job: npc.job))
			}
		}
	}

	private static func talkNormally(kingdom _: Kingdom, _ npc: NPC) async {
		// let building = await Game.shared.getKingdomNPCBuilding(kingdom.id, npcInBuilding: npc.id)
		let options: [MessageOption] = [
			.init(label: "Quit") {},
			.init(label: "Can you make a door?", action: makeDoor),
		]
		await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options).action()
	}

	private static func makeDoor() async {
		let options: [MessageOption] = [
			.init(label: "Quit") {},
		]
		await MessageBox.messageWithOptions("Yes, I can. Which one would you like?", speaker: .game, options: options).action()
	}

	private static func getDoor() async {}

	private static func buildCastle(npc: NPC, kingdom: Kingdom) async {
		if kingdom.data.contains(.gettingStuffToBuildCastle) {
			await MessageBox.message("You are back! Would you like to start working on your castle?", speaker: .npc(name: npc.name, job: npc.job))
			let options: [MessageOption] = [
				.init(label: "Quit", action: {}),
				.init(label: "Build your Castle", action: {}),
			]
			let option = await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options)
			if option.label == options[1].label {
				await Game.shared.player.setCanBuild(true)
				_ = await Game.shared.player.collect(item: .init(type: .door(tile: .init(type: .castle(side: .top))), canBeSold: false))
				await MessageBox.message("Let me know when you are done!", speaker: .npc(name: npc.name, job: npc.job))
				await Game.shared.addKingdomData(.buildingCastle, npcInKindom: npc.id)
				await Game.shared.removeKingdomData(.gettingStuffToBuildCastle, npcInKindom: npc.id)
			} else {
				await MessageBox.message("Ok, let me know when you are ready to start building!", speaker: .npc(name: npc.name, job: npc.job))
			}
		} else if kingdom.data.contains(.buildingCastle) {
			await MessageBox.message("You are back! Would you like to continue working on your castle?", speaker: .npc(name: npc.name, job: npc.job))
			let options: [MessageOption] = [
				.init(label: "I'm still working", action: {}),
				.init(label: "I'm done!", action: {}),
			]
			let option = await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options)
			if option.label == options[1].label {
				if await !Game.shared.player.has(item: .door(tile: .init(type: .castle(side: .top)))) {
					await MessageBox.message("Great! Your castle is now complete!", speaker: .npc(name: npc.name, job: npc.job))
					await Game.shared.removeKingdomData(.buildingCastle, npcInKindom: npc.id)
					await Game.shared.setKingdomCastle(kingdomID: kingdom.id)
				} else {
					await MessageBox.message("You haven't placed your castle door yet.", speaker: .npc(name: npc.name, job: npc.job))
				}
			}
		} else {
			await MessageBox.message("I don't know what to do (1)", speaker: .npc(name: npc.name, job: npc.job))
		}
	}
}
