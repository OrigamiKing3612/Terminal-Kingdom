import Foundation

Screen.clear()
Screen.Cursor.moveToTop()

TerminalInput.enableRawMode()

defer {
	TerminalInput.restoreOriginalMode()
}

if Game.hasInited == false {
	Game.initGame()
	Screen.initialize()
	showTitleScreen()
	mainGameLoop()
}

func showTitleScreen() {
	let option = TitleScreen.show()
	Screen.clear()
	if option == .helpOption {
		option.action
		_ = TerminalInput.readKey()
		showTitleScreen()
	} else if option == .settingsOption {
		option.action
		showTitleScreen()
	} else {
		Screen.initializeBoxes()
		option.action
	}
}

func endProgram() {
	// TODO: Save game
	//    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	//    if let filePath {
	//        let file = filePath.appendingPathComponent("adventure.game.json")
//
	//        do {
	//            let game = CodableGame(location: Game.location, hasInited: Game.hasInited, isTypingInMessageBox: Game.isTypingInMessageBox, player: Game.player, map: Game.map, startingVillageChecks: Game.startingVillageChecks, stages: Game.stages, messages: Game.messages)
	//            let JSON = try JSONEncoder().encode(game)
	//            try JSON.write(to: filePath)
	//        } catch {
//
	//        }
	//    }
	TerminalInput.restoreOriginalMode()
	exit(0)
}

func loadGame() -> Bool {
	let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

	if let filePath {
		let file = filePath.appendingPathComponent("adventure.game.json")
		do {
			let fileData = try Data(contentsOf: file)
			let decodedGame = try JSONDecoder().decode(CodableGame.self, from: fileData)
			Game.reloadGame(decodedGame: decodedGame)
			return true
		} catch {
			// print("Error reading or decoding the file: \(error)")
		}
	}
	return false
}

func newGame() {
	MessageBox.message("Welcome to Adventure!", speaker: .game)
	let playerName = MessageBox.messageWithTyping("Let's create your character. What is your name?", speaker: .game)
	MessageBox.message("Welcome \(playerName)!", speaker: .game)
	Game.player.setName(playerName)
	StatusBox.statusBox()
}

func mainGameLoop() {
	while true {
		if StatusBox.updateQuestBox {
			StatusBox.questArea()
		}
		InventoryBox.inventoryBox()

		guard !Game.isTypingInMessageBox else { continue }

		let key = TerminalInput.readKey()
		if Game.isInInventoryBox {
			Keys.inventory(key: key)
		} else if Game.isBuilding {
			Keys.building(key: key)
		} else {
			Keys.normal(key: key)
		}
	}
}
