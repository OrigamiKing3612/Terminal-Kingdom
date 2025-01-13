enum KingNPC {
	static func talk() {
		if Game.startingVillageChecks.firstTimes.hasTalkedToKing == false {
			Game.startingVillageChecks.firstTimes.hasTalkedToKing = true
			firstDialogue()
		} else {
			help()
		}
	}

	static func help() {
		MessageBox.message("Input help here", speaker: .king)
	}

	static func firstDialogue() {
		MessageBox.message("Welcome to the village, \(Game.player.name).", speaker: .king)
		MessageBox.message("I am the king of this village. I have heard of your arrival and I am glad you are here.", speaker: .king)
		MessageBox.message("I am here to help you navigate this village.", speaker: .king)
		MessageBox.message("Seems like you figured out how to walk. Your goal is to learn how to create your own village and go make your own kingdom! You can learn different skills by talking to different people in the buildings.", speaker: .king)
		MessageBox.message("Now you might be wondering what buttons to press. If you press the \(KeyboardKeys.space.render) or \(KeyboardKeys.enter.render) key, you can interact with the tile you are on.", speaker: .king)
		MessageBox.message("For example, to open a door, you would press one of those keys while standing on the door.", speaker: .king)
		MessageBox.message("You can also press the \("p".styled(with: .bold)) key to see your current location on the map.", speaker: .king)
		MessageBox.message("If you have any questions, feel free to ask me.", speaker: .king)
		// MessageBox.message("I suggest starting with the miner, blacksmith, or the builder.", speaker: .king)
		MessageBox.message("Good luck!", speaker: .king)
	}
}
