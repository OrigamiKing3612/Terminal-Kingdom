enum PotterAreaDoorEvent {
	static func open(tile: DoorTile) async {
		let options: [MessageOption] = [
			.init(label: "Go Inside", action: { goInside(tile: tile) }),
			.init(label: "Quit", action: {}),
		]
		let selectedOption = await MessageBox.messageWithOptions("What would you like to do?", speaker: .game, options: options)
		selectedOption.action()
	}

	static func goInside(tile _: DoorTile) {
		// TODO: Map changed to be a "map" of the building
		MessageBox.message("Its locked.", speaker: .game)
	}
}
