enum HouseDoorEvent: DoorEvent {
	static func open(tile: DoorTile) async {
		var options: [MessageOption] = [
			.init(label: "Go Inside", action: { await goInside(tile: tile) }),
		]
		options.append(.init(label: "Quit", action: {}))
		await MessageBox.messageWithOptions("What would you like to do?", options: options)
	}

	static func goInside(tile _: DoorTile) async {
		// TODO: Map changed to be a "map" of the building
		await MessageBox.message("Its locked.", speaker: .game)
	}
}
