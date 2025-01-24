enum FarmerNPC {
	static func talk() async {
		if await Game.shared.startingVillageChecks.firstTimes.hasTalkedToFarmer == false {
			await Game.shared.startingVillageChecks.setHasTalkedToFarmer()
		}
		let options: [MessageOption] = [
			.init(label: "Yes", action: {}),
			.init(label: "No", action: {}),
		]
		let selectedOption = await MessageBox.messageWithOptions("Hello \(Game.shared.player.name)! Would you like to learn how to be a farmer?", speaker: .farmer, options: options)
		if selectedOption.label == "Yes" {
			await stage1()
		} else {
			return
		}
	}

	static func stage1() async {}
}
