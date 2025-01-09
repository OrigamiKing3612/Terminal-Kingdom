enum BuilderDoorEvent {
	static func open(tile: DoorTile) {
		var options: [MessageOption] = [
			.init(label: "Go Inside", action: { goInside(tile: tile) }),
		]
		if tile.isPartOfPlayerVillage {
			options.append(.init(label: "Upgrade", action: { upgrade(tile: tile) }))
		}
		options.append(.init(label: "Quit", action: {}))
		let selectedOption = MessageBox.messageWithOptions("What would you like to do?", speaker: .game, options: options)
		selectedOption.action()
	}

	static func goInside(tile _: DoorTile) {
		MapBox.mapType = .builder
	}

	static func upgrade(tile _: DoorTile) {
		// TODO: upgrade building
	}
}
