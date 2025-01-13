enum CarpenterNPC {
	static func talk() {
		if Game.stages.blacksmith.stage3Stages == .goToCarpenter {
			MessageBox.message("Here are your sticks.", speaker: .carpenter)
			if let lumberUUIDs = Game.stages.blacksmith.stage3LumberUUIDsToRemove {
				Game.player.removeItems(ids: lumberUUIDs)
			}
			Game.stages.blacksmith.stage3LumberUUIDsToRemove = Game.player.collect(item: .init(type: .stick, canBeSold: false), count: 20)
			Game.stages.blacksmith.stage3Stages = .comeBack
		} else {
			MessageBox.message("I'm busy here...", speaker: .carpenter)
		}
	}
}
