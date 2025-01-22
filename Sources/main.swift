import Foundation

Screen.clear()
Screen.Cursor.moveToTop()

TerminalInput.enableRawMode()

defer {
	TerminalInput.restoreOriginalMode()
}

if Game.hasInited == false {
	await Game.initGame()
	Screen.initialize()
	await showTitleScreen()
	startTasks()
	await mainGameLoop()
}

func showTitleScreen() async {
	let option = TitleScreen.show()
	Screen.clear()
	if option == .helpOption {
		await option.action()
		_ = TerminalInput.readKey()
		await showTitleScreen()
	} else if option == .settingsOption {
		await option.action()
		await showTitleScreen()
	} else {
		Screen.initializeBoxes()
		await option.action()
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

func loadGame() async -> Bool {
	let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

	if let filePath {
		let file = filePath.appendingPathComponent("adventure.game.json")
		do {
			let fileData = try Data(contentsOf: file)
			let decodedGame = try JSONDecoder().decode(CodableGame.self, from: fileData)
			await Game.reloadGame(decodedGame: decodedGame)
			return true
		} catch {
			// print("Error reading or decoding the file: \(error)")
		}
	}
	return false
}

func newGame() async {
	MessageBox.message("Welcome to Adventure!", speaker: .game)
	let playerName = await MessageBox.messageWithTyping("Let's create your character. What is your name?", speaker: .game)
	MessageBox.message("Welcome \(playerName)!", speaker: .game)
	Game.player.setName(playerName)
	StatusBox.statusBox()
}

func startTasks() {
	// TODO: update label
	let cropQueue = DispatchQueue(label: "adventure.cropQueue", qos: .background, attributes: .concurrent)
	let stationsQueue = DispatchQueue(label: "adventure.stationsQueue", qos: .background)

	cropQueue.async {
		// TODO: building maps
		while true {
			if Game.crops.count > 0 {
				for position in Game.crops {
					let tile = MapBox.mainMap.grid[position.y][position.x]
					if case let .crop(crop) = tile.type {
						var newCropTile = CropTile(type: crop.type, growthStage: crop.growthStage)
						newCropTile.grow()
						MapBox.mainMap.grid[position.y][position.x] = .init(type: .crop(crop: newCropTile), isWalkable: tile.isWalkable, event: tile.event)
					}
				}
			}
			sleep(1)
		}
	}
}

func mainGameLoop() async {
	while true {
		if StatusBox.updateQuestBox {
			StatusBox.questArea()
		}
		InventoryBox.inventoryBox()

		guard !Game.isTypingInMessageBox else { continue }

		let key = TerminalInput.readKey()
		if Game.isInInventoryBox {
			await Keys.inventory(key: key)
		} else if Game.isBuilding {
			await Keys.building(key: key)
		} else {
			await Keys.normal(key: key)
		}
	}
}
