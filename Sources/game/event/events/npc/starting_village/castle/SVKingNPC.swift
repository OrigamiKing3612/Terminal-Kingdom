enum SVKingNPC: StartingVillageNPC {
	static func talk() async {
		await NPC.setTalkedTo(after: firstDialogue)
		if await Game.shared.stages.builder.stage4Stages == .talkToKing {
			await MessageBox.message("Hello \(NPCJob.king.render), I am the builders apprentice, we were wondering if we could build a new house in the village?", speaker: .player)
			await MessageBox.message("Hello \(Game.shared.player.name)! Yes that is a good idea.", speaker: .king)
			await MessageBox.message("Ok! Thank you! I'll go let him know", speaker: .player)
			await Game.shared.stages.builder.setStage4Stages(.comeBack)
		} else {
			await help()
		}
	}

	static func help() async {
		// TODO: Move to help popup and show it here
		await MessageBox.message("I'm here to help!", speaker: .king)
		await MessageBox.message("Normal mode:".styled(with: .bold), speaker: .king)
		if await Game.shared.config.wasdKeys {
			await MessageBox.message("  Use \(KeyboardKeys.w.render)\(KeyboardKeys.a.render)\(KeyboardKeys.s.render)\(KeyboardKeys.d.render) keys to move around", speaker: .king)
		} else if await Game.shared.config.vimKeys {
			await MessageBox.message("  Use \(KeyboardKeys.h.render)\(KeyboardKeys.j.render)\(KeyboardKeys.k.render)\(KeyboardKeys.l.render) keys to move around", speaker: .king)
		} else if await Game.shared.config.arrowKeys {
			await MessageBox.message("  Use the \("arrow keys".styled(with: .bold)) to move around", speaker: .king)
		}
		await MessageBox.message("  Press \(KeyboardKeys.space.render) or \(KeyboardKeys.enter.render) to interact with objects", speaker: .king)
		await MessageBox.message("  Press \(KeyboardKeys.Q.render) to quit", speaker: .king)
		await MessageBox.message("Inventory mode:".styled(with: [.bold, .yellow]), speaker: .king)
		await MessageBox.message("  Press \(KeyboardKeys.i.render) to open your inventory", speaker: .king)
		await MessageBox.message("  Press \(KeyboardKeys.up.render) or \(KeyboardKeys.down.render) to cycle through items", speaker: .king)
		await MessageBox.message("  Press \(KeyboardKeys.tab.render) and \(KeyboardKeys.back_tab.render) to cycle through items", speaker: .king)
		await MessageBox.message("  Press \(KeyboardKeys.d.render) to destroy an item", speaker: .king)
		await MessageBox.message("  Press \(KeyboardKeys.questionMark.render) for help", speaker: .king)
		if await Game.shared.player.canBuild {
			await MessageBox.message("Build mode:".styled(with: [.bold, .blue]), speaker: .king)
			await MessageBox.message("  Press \(KeyboardKeys.b.render) to enter build mode", speaker: .king)
			await MessageBox.message("  Press \(KeyboardKeys.e.render) to destroy", speaker: .king)
			await MessageBox.message("  Press \(KeyboardKeys.tab.render) and \(KeyboardKeys.back_tab.render) to cycle through buildable items", speaker: .king)
			await MessageBox.message("  Press \(KeyboardKeys.questionMark.render) for help", speaker: .king)
		}
		await MessageBox.message("Press \(KeyboardKeys.zero.render) to reload the UI", speaker: .king)
		await MessageBox.message("Press \(KeyboardKeys.esc.render) to exit any mode", speaker: .king)
		await MessageBox.message("Press \(KeyboardKeys.W.render) or \(KeyboardKeys.S.render) to scroll up and down in the message box", speaker: .king)
	}

	static func firstDialogue() async {
		await MessageBox.message("Welcome to the village, \(Game.shared.player.name).", speaker: .king)
		await MessageBox.message("I am the king of this village. I have heard of your arrival and I am glad you are here.", speaker: .king)
		await MessageBox.message("I am here to help you navigate this village.", speaker: .king)
		await MessageBox.message("Seems like you figured out how to walk. Your goal is to learn how to create your own village and go make your own kingdom! You can learn different skills by talking to different people in the buildings.", speaker: .king)
		await MessageBox.message("Now you might be wondering what buttons to press. If you press the \(KeyboardKeys.space.render) or \(KeyboardKeys.enter.render) key, you can interact with the tile you are on.", speaker: .king)
		await MessageBox.message("For example, to open a door, you would press one of those keys while standing on the door.", speaker: .king)
		await MessageBox.message("If you have any questions, feel free to ask me.", speaker: .king)
		// await MessageBox.message("I suggest starting with the miner, blacksmith, or the builder.", speaker: .king)
		await MessageBox.message("Good luck!", speaker: .king)
	}
}
