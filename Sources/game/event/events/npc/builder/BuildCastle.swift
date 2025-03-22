import Foundation

enum BuildCastle {
	static func buildCastle(npc: NPC) async -> Bool {
		switch await Game.shared.kingdom.data.castleStage {
			case .notStarted:
				await MessageBox.message("Hello, I'm \(npc.name)! I can help you with building. Let's start! Go get all of the materials you need and then we can build your castle!", speaker: .npc(name: npc.name, job: npc.job))
				await Game.shared.player.setCanBuild(false)
				await Game.shared.kingdom.data.setCastleStage(.gettingStuff)
				return true
			case .gettingStuff:
				await gettingStuff(npc: npc)
				return true
			case .building:
				await building(npc: npc)
				return true
			case .done:
				return false
		}
	}

	static func gettingStuff(npc: NPC) async {
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
			await Game.shared.kingdom.data.setCastleStage(.building)
			await Game.shared.setRestrictBuilding((true, .init(x: Game.shared.player.position.x, y: Game.shared.player.position.y, mapType: .mainMap)))
		} else {
			await MessageBox.message("Ok, let me know when you are ready to start building!", speaker: .npc(name: npc.name, job: npc.job))
		}
	}

	static func building(npc: NPC) async {
		let options: [MessageOption] = [
			.init(label: "I'm still working", action: {}),
			.init(label: "I'm done!", action: {}),
		]
		let option = await MessageBox.messageWithOptions("You are back! Are you done working on your your castle?", speaker: .npc(name: npc.name, job: npc.job), options: options)
		if option.label == options[1].label {
			if await !Game.shared.player.has(item: .door(tile: .init(type: .castle(side: .top)))) {
				await MessageBox.message("Great! Your castle is now complete! Come back to me when you want to build the courthouse!", speaker: .npc(name: npc.name, job: npc.job))
				await Game.shared.kingdom.data.setCastleStage(.done)
				await Game.shared.setRestrictBuilding((false, .init(x: 0, y: 0, mapType: .mainMap)))
			} else {
				await MessageBox.message("You haven't placed your castle door yet.", speaker: .npc(name: npc.name, job: npc.job))
			}
		}
	}
}
