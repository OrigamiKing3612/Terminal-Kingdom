import Foundation

enum EditKingdomEvent {
	static func editKingdom() async {
		// TODO: make this into a pop up
		var exit = false
		let kingdom = await Game.shared.kingdom
		while !exit {
			let options: [MessageOption] = [
				.init(label: "Quit", action: { exit = true }),
				.init(label: "Rename Kingdom", action: { await renameKingdom() }),
			]
			await MessageBox.message("Editing \(kingdom.name):", speaker: .game)
			await MessageBox.messageWithOptions("What do you want to do?", speaker: .game, options: options).action()
		}
	}

	static func renameKingdom() async {
		let name = await MessageBox.messageWithTyping("New Name:", speaker: .game)
		if !name.isEmpty {
			await Game.shared.renameKingdom(newName: name)
		}
	}
}
