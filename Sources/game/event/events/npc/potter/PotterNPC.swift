enum PotterNPC {
	static func talk() async {
		if await !Game.shared.startingVillageChecks.firstTimes.hasTalkedToPotter {
			await MessageBox.message("Hello \(Game.shared.player.name)!  I'm the potter. I make pots. I'll make you a pot for 2 clay or 5 coins!", speaker: .potter)
			await Game.shared.startingVillageChecks.setHasTalkedToPotter()
		}
		await potterStuff()
	}

	static func potterStuff() async {
		var options: [MessageOption] = [
			.init(label: "Quit", action: {}),
		]
		if await Game.shared.player.has(item: .clay, count: 2) {
			options.append(.init(label: "Buy a pot for 2 clay", action: {
				await buyPot()
				await Game.shared.player.removeItem(item: .clay, count: 2)
				if await Game.shared.stages.farm.stage5Stages == .collect {
					await Game.shared.stages.farm.setStage5Stages(.comeBack)
				}
			}))
		}
		if await Game.shared.player.has(item: .coin, count: 5) {
			options.append(.init(label: "Buy a pot for 5 coins", action: {
				await buyPot()
				await Game.shared.player.removeItem(item: .coin, count: 5)
			}))
		}

		await MessageBox.message("Hello \(Game.shared.player.name)!", speaker: .potter)
		await MessageBox.messageWithOptions("What would you like to do?", speaker: .potter, options: options).action()
	}

	static func buyPot() async {
		_ = await Game.shared.player.collect(item: .init(type: .pot))
		await MessageBox.message("I hope to see you again!", speaker: .potter)
	}
}
