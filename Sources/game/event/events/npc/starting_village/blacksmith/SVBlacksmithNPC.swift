enum SVBlacksmithNPC: StartingVillageNPC {
	static func talk() async {
		await MessageBox.message("I'm busy here...", speaker: .blacksmith)
	}
}
