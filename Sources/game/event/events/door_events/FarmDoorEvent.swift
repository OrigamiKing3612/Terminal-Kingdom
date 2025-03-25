enum FarmDoorEvent: DoorEvent {
	static func open(tile: DoorTile) async {
		var options: [MessageOption] = [
			.init(label: "Go Inside", action: { await goInside(tile: tile) }),
		]
		options.append(.init(label: "Quit", action: {}))
		await MessageBox.messageWithOptions("What would you like to do?", options: options)
	}

	static func goInside(tile: DoorTile) async {
		if case let .farm(type: type) = tile.type {
			await MapBox.setMapType(.farm(type: type))
		}
	}
}
