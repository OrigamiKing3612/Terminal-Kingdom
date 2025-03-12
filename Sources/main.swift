import Foundation

Screen.clear()
Screen.Cursor.moveToTop()

TerminalInput.enableRawMode()

defer {
	TerminalInput.restoreOriginalMode()
}

if await Game.shared.hasInited == false {
	Screen.initialize()
	await Game.shared.initGame()
	MapBoxActor.shared = await MapBoxActor()
	await showTitleScreen()
	// await startCropQueue()
	await mainGameLoop()
}

func showTitleScreen() async {
	var screen = TitleScreen()
	let option = await screen.show()
	Screen.clear()
	if option == .helpOption {
		await option.action(screen: &screen)
		_ = TerminalInput.readKey()
		await showTitleScreen()
	} else if option == .settingsOption {
		await option.action(screen: &screen)
		await showTitleScreen()
	} else {
		await Screen.initializeBoxes()
		await option.action(screen: &screen)
	}
}

func endProgram() {
	// TODO: Save game
	//    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	//    if let filePath {
	//        let file = filePath.appendingPathComponent("terminalkingdom.game.json")
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
	Screen.clear()
	exit(0)
}

func loadGame() async -> Bool {
	// let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	//
	// if let filePath {
	// 	let file = filePath.appendingPathComponent("terminalkingdom.game.json")
	// 	do {
	// 		let fileData = try Data(contentsOf: file)
	// 		let decodedGame = try JSONDecoder().decode(CodableGame.self, from: fileData)
	// 		await Game.shared.reloadGame(decodedGame: decodedGame)
	// 		return true
	// 	} catch {
	// 		// print("Error reading or decoding the file: \(error)")
	// 	}
	// }
	false
}

func newGame() async {
	await MessageBox.message("Welcome to Terminal Kingdom!", speaker: .game)
	let playerName = await MessageBox.messageWithTyping("Let's create your character. What is your name?", speaker: .game)
	await MessageBox.message("Welcome \(playerName)!", speaker: .game)
	await Game.shared.player.setName(playerName)
	await StatusBox.statusBox()
}

func startNPCMovingQueue() async {
	let npcQueue = DispatchQueue(label: "com.origamiking3612.terminalkingdom.npcs", qos: .background, attributes: .concurrent)

	npcQueue.async {
		Task {
			while true {
				let npcPositions = await Game.shared.npcs

				guard !npcPositions.isEmpty else {
					try? await Task.sleep(for: .seconds(0.5))
					continue
				}

				for position in npcPositions {
					let npcTile = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile

					if case let .npc(npc) = npcTile.type, let positionToWalkTo = npc.positionToWalkTo {
						let newNpcPosition = await NPCMoving.move(
							target: positionToWalkTo,
							current: .init(x: position.x, y: position.y, mapType: position.mapType)
						)

						// Capture the original tile before modifying it
						let oldTile = await MapBox.mapType.map.grid[newNpcPosition.y][newNpcPosition.x] as! MapTile

						let newPosition = NPCPosition(
							x: newNpcPosition.x,
							y: newNpcPosition.y,
							mapType: position.mapType,
							oldTile: oldTile // Store old tile
						)

						// Restore old tile state
						await MapBox.setMapGridTile(
							x: position.x,
							y: position.y,
							tile: oldTile, // Correct old tile reference
							mapType: position.mapType
						)

						// Update new tile with NPC
						await MapBox.setMapGridTile(
							x: newNpcPosition.x,
							y: newNpcPosition.y,
							tile: MapTile(
								type: .npc(tile: npc),
								isWalkable: npcTile.isWalkable,
								event: npcTile.event,
								biome: npcTile.biome
							),
							mapType: position.mapType
						)

						// Update NPC's position in Game state
						await Game.shared.updateNPC(oldPosition: position, newPosition: newPosition)
						await MapBox.mapBox()
					}
				}
				try? await Task.sleep(for: .seconds(0.5))
			}
		}
	}
}

func startCropQueue() async {
	let cropQueue = DispatchQueue(label: "com.origamiking3612.terminalkingdom.cropQueue", qos: .background, attributes: .concurrent)
	// let stationsQueue = DispatchQueue(label: "com.origamiking3612.terminalkingdom.stationsQueue", qos: .background)

	cropQueue.async {
		// TODO: building maps
		Task {
			while true {
				if await Game.shared.crops.count > 0 {
					for position in await Game.shared.crops {
						switch position.mapType {
							case .custom:
								// TODO: custom map crop growing maybe?
								break
							case .farm:
								let tile = await Game.shared.maps.farm[position.y][position.x]
								if case let .pot(tile: pot) = tile.type {
									var newPotTile = PotTile(cropTile: pot.cropTile)
									newPotTile.grow()
									let isInsideFarm = await MapBox.mapType == .farm(type: .main)
									let isInsideFarm2 = await MapBox.mapType == .farm(type: .farm_area)
									if isInsideFarm || isInsideFarm2 {
										await MapBox.setMapGridTile(x: position.x, y: position.y, tile: .init(type: .pot(tile: newPotTile), isWalkable: tile.isWalkable, event: tile.event, biome: tile.biome), mapType: position.mapType)
									} else {
										await Game.shared.maps.updateMap(mapType: .farm(type: .main), x: position.x, y: position.y, tile: .init(type: .pot(tile: newPotTile), isWalkable: tile.isWalkable, event: tile.event, biome: tile.biome))
									}
								}
							case .mainMap:
								let tile = await MapBox.mainMap.grid[position.y][position.x]
								if case let .crop(crop) = tile.type {
									var newCropTile = CropTile(type: crop.type, growthStage: crop.growthStage)
									newCropTile.grow()
									await MapBox.setMapGridTile(x: position.x, y: position.y, tile: .init(type: .crop(crop: newCropTile), isWalkable: tile.isWalkable, event: tile.event, biome: tile.biome), mapType: position.mapType)
								} else if case let .pot(tile: pot) = tile.type {
									var newPotTile = PotTile(cropTile: pot.cropTile)
									newPotTile.grow()
									await MapBox.setMapGridTile(x: position.x, y: position.y, tile: .init(type: .pot(tile: newPotTile), isWalkable: tile.isWalkable, event: tile.event, biome: tile.biome), mapType: position.mapType)
								}
							default: break
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
			await StatusBox.questArea()
		}
		if InventoryBox.updateInventoryBox {
			await InventoryBox.inventoryBox()
		}
		if InventoryBox.updateInventory {
			await InventoryBox.printInventory()
		}

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
