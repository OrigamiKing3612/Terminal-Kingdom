enum CarpenterNPC {
	static func talk() {
		if await Game.shared.stages.blacksmith.stage3Stages == .goToCarpenter {
			MessageBox.message("Here are your sticks.", speaker: .carpenter)
			if let lumberUUIDs = await Game.shared.stages.blacksmith.stage3LumberUUIDsToRemove {
				await Game.shared.player.removeItems(ids: lumberUUIDs)
			}
			await Game.shared.stages.blacksmith.stage3LumberUUIDsToRemove = await Game.shared.player.collect(item: .init(type: .stick, canBeSold: false), count: 20)
			await Game.shared.stages.blacksmith.stage3Stages = .comeBack
		} else {
			MessageBox.message("I'm busy here...", speaker: .carpenter)
		}
	}
}
