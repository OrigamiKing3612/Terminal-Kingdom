import Foundation

enum CustomDoorEvent {
	static func open(tile: DoorTile, mapID: UUID?, doorType _: DoorTileTypes) {
		guard let mapID else {
			MessageBox.message("This building doesn't have an inside. Try breaking and replacing the door.", speaker: .game)
			return
		}
		var options: [MessageOption] = [
			.init(label: "Go Inside", action: { goInside(tile: tile, mapID: mapID) }),
		]
		if tile.isPartOfPlayerVillage {
			options.append(.init(label: "Upgrade", action: { upgrade(tile: tile) }))
		}
		options.append(.init(label: "Quit", action: {}))
		let selectedOption = MessageBox.messageWithOptions("What would you like to do?", speaker: .game, options: options)
		selectedOption.action()
	}

	static func goInside(tile _: DoorTile, mapID: UUID) {
		MapBox.mapType = .custom(mapID: mapID)
	}

	static func upgrade(tile _: DoorTile) {
		// TODO: upgrade building
	}
}
