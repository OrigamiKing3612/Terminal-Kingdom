import Foundation

enum BuildCourthouse {
	static func buildCourthouse(npc _: NPC, village _: Village) async {
		#warning("Finish this")
		// if await village.data.contains(.gettingStuffToBuildCourthouse) {
		// 	await MessageBox.message("You are back! Would you like to start working on your the courthouse?", speaker: .npc(name: npc.name, job: npc.job))
		// 	let options: [MessageOption] = [
		// 		.init(label: "Quit", action: {}),
		// 		.init(label: "Build your Castle", action: {}),
		// 	]
		// 	let option = await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options)
		// 	if option.label == options[1].label {
		// 		await Game.shared.player.setCanBuild(true)
		// 		_ = await Game.shared.player.collect(item: .init(type: .door(tile: .init(type: .castle(side: .top))), canBeSold: false))
		// 		await MessageBox.message("Let me know when you are done!", speaker: .npc(name: npc.name, job: npc.job))
		// 		await Game.shared.kingdom.addVillageData(.buildingCourthouse, npcInVillage: npc.id)
		// 		await Game.shared.kingdom.removeVillageData(.gettingStuffToBuildCourthouse, npcInVillage: npc.id)
		// 		await Game.shared.setRestrictBuilding((true, .init(x: Game.shared.player.position.x, y: Game.shared.player.position.y, mapType: .mainMap)))
		// 	} else {
		// 		await MessageBox.message("Ok, let me know when you are ready to start building!", speaker: .npc(name: npc.name, job: npc.job))
		// 	}
		// } else if await village.data.contains(.buildingCourthouse) {
		// 	let options: [MessageOption] = [
		// 		.init(label: "I'm still working", action: {}),
		// 		.init(label: "I'm done!", action: {}),
		// 	]
		// 	let option = await MessageBox.messageWithOptions("You are back! Would you like to continue working on the courthouse?", speaker: .npc(name: npc.name, job: npc.job), options: options)
		// 	if option.label == options[1].label {
		// 		if await !Game.shared.player.has(item: .door(tile: .init(type: .castle(side: .top)))) {
		// 			await MessageBox.message("Great! Your castle is now complete!", speaker: .npc(name: npc.name, job: npc.job))
		// 			await Game.shared.kingdom.removeVillageData(.buildingCourthouse, npcInVillage: npc.id)
		// 			await Game.shared.kingdom.setVillageCourthouse(villageID: village.id)
		// 			await Game.shared.setRestrictBuilding((false, .init(x: 0, y: 0, mapType: .mainMap)))
		// 		} else {
		// 			await MessageBox.message("You haven't placed your castle door yet.", speaker: .npc(name: npc.name, job: npc.job))
		// 		}
		// 	}
		// } else {
		// 	await MessageBox.message("I don't know what to do (1)", speaker: .npc(name: npc.name, job: npc.job))
		// }
	}
}
