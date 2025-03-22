import Foundation

struct CourthouseDoorEvent: DoorEvent {
	static func open(tile: DoorTile) async {
		var options: [MessageOption] = [
			.init(label: "Go Inside", action: { await goInside(tile: tile) }),
		]
		options.append(.init(label: "Quit", action: {}))
		let selectedOption = await MessageBox.messageWithOptions("What would you like to do?", speaker: .game, options: options)
		await selectedOption.action()
	}

	static func goInside(tile _: DoorTile) async {
		Logger.warning("\(#fileID) \(#function) This shouldn't have been called. (This will should always be called inside of custom door event)")
	}
}
