import Foundation

enum CustomDoorEvent {
	static func open(tile: DoorTile, mapID: UUID?, doorType _: DoorTileTypes) async {
		guard let mapID else {
			await MessageBox.message("This building doesn't have an inside. Try breaking and replacing the door.", speaker: .game)
			return
		}
		var options: [MessageOption] = [
			.init(label: "Go Inside", action: { await goInside(tile: tile, mapID: mapID) }),
		]
		if tile.isPartOfPlayerVillage {
			options.append(.init(label: "Upgrade", action: { upgrade(tile: tile) }))
		}
		options.append(.init(label: "Quit", action: {}))
		let selectedOption = await MessageBox.messageWithOptions("What would you like to do?", speaker: .game, options: options)
		await selectedOption.action()
	}

	static func goInside(tile _: DoorTile, mapID: UUID) async {
		await MapBox.setMapType(.custom(mapID: mapID))
	}

	static func upgrade(tile _: DoorTile) {
		// TODO: upgrade building
	}
}
