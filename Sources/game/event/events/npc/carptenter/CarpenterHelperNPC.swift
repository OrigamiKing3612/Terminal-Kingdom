enum CarpenterHelperNPC {
	static func talk() async {
		await MessageBox.message("I'm busy here...", speaker: .carpenter_helper)
	}
}
