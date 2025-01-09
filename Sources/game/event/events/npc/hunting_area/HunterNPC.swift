enum HunterNPC {
	static func talk() {
		if Game.startingVillageChecks.firstTimes.hasTalkedToHunter == false {
			Game.startingVillageChecks.firstTimes.hasTalkedToHunter = true
		} else if Game.stages.blacksmith.stage7Stages == .bringToHunter {
			Game.stages.blacksmith.stage7Stages = .comeBack
			MessageBox.message("Hello \(Game.player.name)! Thank you for this sword!!", speaker: .hunter)
			if let id = Game.stages.blacksmith.stage7SwordUUIDToRemove {
				Game.player.removeItem(id: id)
			}
		} else {
			getStage()
		}
	}

	static func getStage() {
		let options: [MessageOption] = [
			.init(label: "Yes", action: {}),
			.init(label: "No", action: {}),
		]
		let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to be a hunter?", speaker: .hunter, options: options)
		if selectedOption.label == "Yes" {
			stage1()
		} else {
			return
		}
	}

	static func stage1() {}
}
