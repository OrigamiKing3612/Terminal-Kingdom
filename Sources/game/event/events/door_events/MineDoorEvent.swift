enum MineDoorEvent {
	static func open(tile: DoorTile) async {
		var options: [MessageOption] = [
			.init(label: "Go Inside", action: { goInside(tile: tile) }),
		]
		if await Game.shared.player.has(item: .lumber, count: 100), await Game.shared.player.has(item: .iron, count: 20), await Game.shared.player.has(item: .stone, count: 30), await Game.shared.stages.mine.stage7Stages == .upgrade {
			options.append(.init(label: "Upgrade", action: { upgrade(tile: tile) }))
		}
		options.append(.init(label: "Quit", action: {}))
		let selectedOption = await MessageBox.messageWithOptions("What would you like to do?", speaker: .game, options: options)
		selectedOption.action()
	}

	static func goInside(tile _: DoorTile) {
		MapBox.mapType = .mine
	}

	static func upgrade(tile: DoorTile) {
		if let ids = await Game.shared.stages.mine.stage7ItemUUIDsToRemove {
			await Game.shared.stages.mine.stage7Stages = .upgraded
			await Game.shared.player.removeItems(ids: ids)
			goInside(tile: tile)
		}
	}
}
