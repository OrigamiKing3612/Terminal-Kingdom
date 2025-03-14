enum FarmerHelperNPC {
	static func talk() async {
		await MessageBox.message("I'm busy here...", speaker: .farmer_helper)
	}
}
