enum CastleDoorEvent {
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

	static func goInside(tile: DoorTile) {
		if case let .castle(side: side) = tile.type {
			MapBox.mapType = .castle(side: side)
		}
	}

	static func upgrade(tile _: DoorTile) {
		// TODO: upgrade building
	}
}
