enum FarmerNPC {
	static func talk() {
		if Game.startingVillageChecks.firstTimes.hasTalkedToFarmer == false {
			Game.startingVillageChecks.firstTimes.hasTalkedToFarmer = true
		}
		let options: [MessageOption] = [
			.init(label: "Yes", action: {}),
			.init(label: "No", action: {}),
		]
		let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to be a farmer?", speaker: .farmer, options: options)
		if selectedOption.label == "Yes" {
			stage1()
		} else {
			return
		}
	}

	static func stage1() {}
}
