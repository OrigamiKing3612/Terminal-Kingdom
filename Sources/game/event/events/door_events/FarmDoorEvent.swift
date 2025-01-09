enum FarmDoorEvent {
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
		if case let .farm(type: type) = tile.type {
			MapBox.mapType = .farm(type: type)
		}
	}

	static func upgrade(tile _: DoorTile) {
		// TODO: upgrade building
	}
}

enum FarmStage1Stages: Codable {
	case notStarted, mine, done
}
