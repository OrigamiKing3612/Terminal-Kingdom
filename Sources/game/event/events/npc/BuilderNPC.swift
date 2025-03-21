import Foundation

struct BuilderNPC: TalkableNPC {
	//! TODO: Make this work with courthouse
	static func talk(npc: NPC) async {
		if !npc.hasTalkedToBefore {
			await NPC.setTalkedTo {
				await MessageBox.message("Hello, I'm \(npc.name)! I can help you with building. Let's start! Go get all of the materials you need and then we can build your castle!", speaker: .npc(name: npc.name, job: npc.job))
				await Game.shared.player.setCanBuild(false)
				await Game.shared.kingdom.addVillageData(.gettingStuffToBuildCourthouse, npcInVillage: npc.id)
			}
		} else {
			let village = await Game.shared.kingdom.getVillage(for: npc)
			if let village {
				if await !village.hasCourthouse {
					await buildCastle(npc: npc, village: village)
				} else {
					await talkNormally(village: village, npc)
				}
			} else {
				await MessageBox.message("I don't know what to do (2)", speaker: .npc(name: npc.name, job: npc.job))
			}
		}
	}

	private static func talkNormally(village _: Village, _ npc: NPC) async {
		// let building = await Game.shared.getKingdomNPCBuilding(village.id, npcInBuilding: npc.id)
		let options: [MessageOption] = [
			.init(label: "Quit") {},
			.init(label: "Can you make a door?", action: { await makeDoor(npc: npc) }),
		]
		await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options).action()
	}

	private static func makeDoor(npc: NPC) async {
		var options: [MessageOption] = [
			.init(label: "Quit") {},
		]
		for unlockedDoor in await Game.shared.player.unlockedDoors {
			options.append(.init(label: unlockedDoor.name, action: { await getDoor(unlockedDoor, npc: npc) }))
		}
		await MessageBox.messageWithOptions("Yes, I can. Which one would you like?", speaker: .game, options: options).action()
	}

	private static func getDoor(_ doorType: DoorTileTypes, npc: NPC) async {
		let items = doorType.price.items
		let messageItems = items.map {
			"\($0.count) \($0.item.inventoryName)"
		}.joined(separator: ", ")
		await MessageBox.message("To make this door I need: \(messageItems)", speaker: npc)
		var options: [MessageOption] = [
			.init(label: "Nevermind") {},
		]
		if await Game.shared.player.has(items: items) {
			options.append(.init(label: "Yes, I have the items", action: { _ = await Game.shared.player.collect(item: .init(type: .door(tile: .init(type: doorType)), canBeSold: true)) }))
		}
		await MessageBox.messageWithOptions("Do you have the items?", speaker: .npc(name: npc.name, job: npc.job), options: options).action()
	}

	private static func buildCastle(npc: NPC, village: Village) async {
		if await village.data.contains(.gettingStuffToBuildCourthouse) {
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
				await Game.shared.kingdom.addVillageData(.buildingCourthouse, npcInVillage: npc.id)
				await Game.shared.kingdom.removeVillageData(.gettingStuffToBuildCourthouse, npcInVillage: npc.id)
				await Game.shared.setRestrictBuilding((true, .init(x: Game.shared.player.position.x, y: Game.shared.player.position.y, mapType: .mainMap)))
			} else {
				await MessageBox.message("Ok, let me know when you are ready to start building!", speaker: .npc(name: npc.name, job: npc.job))
			}
		} else if await village.data.contains(.buildingCourthouse) {
			await MessageBox.message("You are back! Would you like to continue working on your castle?", speaker: .npc(name: npc.name, job: npc.job))
			let options: [MessageOption] = [
				.init(label: "I'm still working", action: {}),
				.init(label: "I'm done!", action: {}),
			]
			let option = await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options)
			if option.label == options[1].label {
				if await !Game.shared.player.has(item: .door(tile: .init(type: .castle(side: .top)))) {
					await MessageBox.message("Great! Your castle is now complete!", speaker: .npc(name: npc.name, job: npc.job))
					await Game.shared.kingdom.removeVillageData(.buildingCourthouse, npcInVillage: npc.id)
					await Game.shared.kingdom.setVillageCastle(villageID: village.id)
					await Game.shared.setRestrictBuilding((false, .init(x: 0, y: 0, mapType: .mainMap)))
				} else {
					await MessageBox.message("You haven't placed your castle door yet.", speaker: .npc(name: npc.name, job: npc.job))
				}
			}
		} else {
			await MessageBox.message("I don't know what to do (1)", speaker: .npc(name: npc.name, job: npc.job))
		}
	}
}
