import Foundation

enum EditKingdomEvent {
	static func editKingdom(villageID: UUID) async {
		// TODO: make this into a pop up
		var exit = false
		while !exit {
			guard let village = await Game.shared.kingdom.get(villageID: villageID) else {
				await MessageBox.message("An error has occurred", speaker: .game)
				return
			}
			let options: [MessageOption] = [
				.init(label: "Quit", action: { exit = true }),
				.init(label: "Rename Kingdom", action: { await renameKingdom(village: village) }),
			]
			await MessageBox.message("Editing \(village.name):", speaker: .game)
			await MessageBox.messageWithOptions("What do you want to do?", speaker: .game, options: options).action()
		}
	}

	static func renameKingdom(village: Village) async {
		let name = await MessageBox.messageWithTyping("New Name:", speaker: .game)
		if !name.isEmpty {
			await Game.shared.kingdom.renameVillage(id: village.id, name: name)
		}
	}
}
