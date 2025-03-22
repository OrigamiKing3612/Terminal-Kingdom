import Foundation

struct BuilderNPC: TalkableNPC {
	static func talk(npc: NPC) async {
		if !npc.hasTalkedToBefore { await NPC.setTalkedTo() }

		if await BuildCastle.buildCastle(npc: npc) {
			return
		}

		guard let village = await Game.shared.kingdom.getVillage(for: npc) else { return }
		if await BuildCourthouse.buildCourthouse(npc: npc, village: village) {
			return
		}
		await talkNormally(village: village, npc)
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
}
