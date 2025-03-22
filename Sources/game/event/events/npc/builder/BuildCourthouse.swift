import Foundation

enum BuildCourthouse {
	static func buildCourthouse(npc: NPC, village: Village) async -> Bool {
		switch await village.data.courthouseStage {
			case .notStarted:
				await MessageBox.message("Go get all of the materials you need and then we can build the courthouse!", speaker: .npc(name: npc.name, job: npc.job))
				await Game.shared.player.setCanBuild(false)
				await Game.shared.kingdom.villages[village.id]?.data.setCourthouseStage(.gettingStuff)
				return true
			case .gettingStuff:
				await gettingStuff(npc: npc, village: village)
				return true
			case .building:
				await building(npc: npc, village: village)
				return true
			case .done:
				return false
		}
	}

	static func gettingStuff(npc: NPC, village: Village) async {
		await MessageBox.message("You are back! Would you like to start working on your the courthouse?", speaker: .npc(name: npc.name, job: npc.job))
		let options: [MessageOption] = [
			.init(label: "Quit", action: {}),
			.init(label: "Build the courthouse", action: {}),
		]
		let option = await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options)
		if option.label == options[1].label {
			await Game.shared.player.setCanBuild(true)
			_ = await Game.shared.player.collect(item: .init(type: .door(tile: .init(type: .courthouse)), canBeSold: false))
			await MessageBox.message("Let me know when you are done!", speaker: .npc(name: npc.name, job: npc.job))
			await Game.shared.kingdom.villages[village.id]?.data.setCourthouseStage(.building)
			await Game.shared.setRestrictBuilding((true, .init(x: Game.shared.player.position.x, y: Game.shared.player.position.y, mapType: .mainMap)))
		} else {
			await MessageBox.message("Ok, let me know when you are ready to start building!", speaker: .npc(name: npc.name, job: npc.job))
		}
	}

	static func building(npc: NPC, village: Village) async {
		let options: [MessageOption] = [
			.init(label: "I'm still working", action: {}),
			.init(label: "I'm done!", action: {}),
		]
		let option = await MessageBox.messageWithOptions("You are back! Would you like to continue working on the courthouse?", speaker: .npc(name: npc.name, job: npc.job), options: options)
		if option.label == options[1].label {
			if await !Game.shared.player.has(item: .door(tile: .init(type: .courthouse))) {
				await MessageBox.message("Great! The courthouse is now complete!", speaker: .npc(name: npc.name, job: npc.job))
				await Game.shared.kingdom.villages[village.id]?.data.setCourthouseStage(.done)
				await Game.shared.kingdom.setVillageCourthouse(villageID: village.id)
				await Game.shared.setRestrictBuilding((false, .init(x: 0, y: 0, mapType: .mainMap)))
			} else {
				await MessageBox.message("You haven't placed the courthouse door yet.", speaker: .npc(name: npc.name, job: npc.job))
			}
		}
	}
}
