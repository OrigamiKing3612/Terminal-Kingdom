import Foundation

Screen.clear()
Screen.Cursor.moveToTop()

TerminalInput.enableRawMode()

defer {
	TerminalInput.restoreOriginalMode()
}

if await Game.shared.hasInited == false {
	await Game.shared.initGame()
	Screen.initialize()
	await showTitleScreen()
	await startTasks()
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
	//            let game = CodableGame(location: await Game.shared.location, hasInited: await Game.shared.hasInited, isTypingInMessageBox: await Game.shared.isTypingInMessageBox, player: await Game.shared.player, map: await Game.shared.map, startingVillageChecks: await Game.shared.startingVillageChecks, stages: await Game.shared.stages, messages: await Game.shared.messages)
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
			await Game.shared.reloadGame(decodedGame: decodedGame)
			return true
		} catch {
			// print("Error reading or decoding the file: \(error)")
		}
	}
	return false
}

func newGame() async {
	await MessageBox.message("Welcome to Adventure!", speaker: .game)
	let playerName = await MessageBox.messageWithTyping("Let's create your character. What is your name?", speaker: .game)
	await MessageBox.message("Welcome \(playerName)!", speaker: .game)
	await Game.shared.player.setName(playerName)
	StatusBox.statusBox()
}

func startTasks() async {
	// TODO: update label
	let cropQueue = DispatchQueue(label: "adventure.cropQueue", qos: .background, attributes: .concurrent)
	let stationsQueue = DispatchQueue(label: "adventure.stationsQueue", qos: .background)

	cropQueue.async {
		// TODO: building maps
		Task {
			while true {
				if await Game.shared.crops.count > 0 {
					for position in await Game.shared.crops {
						let tile = MapBox.mainMap.grid[position.y][position.x]
						if case let .crop(crop) = tile.type {
							var newCropTile = CropTile(type: crop.type, growthStage: crop.growthStage)
							newCropTile.grow()
							MapBox.mainMap.grid[position.y][position.x] = .init(type: .crop(crop: newCropTile), isWalkable: tile.isWalkable, event: tile.event)
						}
					}
				}
				try? await Task.sleep(for: .seconds(1))
			}
		}
	}
}

func mainGameLoop() async {
	while true {
		if StatusBox.updateQuestBox {
			StatusBox.questArea()
		}
		await InventoryBox.inventoryBox()

		guard await !(Game.shared.isTypingInMessageBox) else { continue }

		let key = TerminalInput.readKey()
		if await Game.shared.isInInventoryBox {
			await Keys.inventory(key: key)
		} else if await Game.shared.isBuilding {
			await Keys.building(key: key)
		} else {
			await Keys.normal(key: key)
		}
	}
}
