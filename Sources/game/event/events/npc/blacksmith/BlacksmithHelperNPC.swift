enum BlacksmithHelperNPC {
	static func talk() async {
		await MessageBox.message("I'm busy here...", speaker: .blacksmith_helper)
	}
}
