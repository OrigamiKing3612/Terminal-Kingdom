enum Keys {
	static func normal(key: KeyboardKeys) async {
		switch key {
			case .q:
				endProgram()
			case .w where await Game.shared.config.wasdKeys, .up where await Game.shared.config.arrowKeys, .k where await Game.shared.config.vimKeys:
				MapBox.movePlayer(.up)
			case .a where await Game.shared.config.wasdKeys, .left where await Game.shared.config.arrowKeys, .h where await Game.shared.config.vimKeys:
				MapBox.movePlayer(.left)
			case .s where await Game.shared.config.wasdKeys, .down where await Game.shared.config.arrowKeys, .j where await Game.shared.config.vimKeys:
				MapBox.movePlayer(.down)
			case .d where await Game.shared.config.wasdKeys, .right where await Game.shared.config.arrowKeys, .l where await Game.shared.config.vimKeys:
				MapBox.movePlayer(.right)
			case .space, .enter:
				await MapBox.interactWithTile()
			case .L where MapBox.mapType == .mining:
				MapBox.mapType = .mine
				MapBox.buildingMap.player.x = 2
				MapBox.buildingMap.player.y = 2
				MapBox.mapBox()
			#if DEBUG
				case .o:
					let tile = MapBox.mapType.map.tilePlayerIsOn as! MapTile
					if let event = tile.event {
						if case let .crop(crop: cropTile) = tile.type {
							MessageBox.message("tileType: \(tile.type.name), tileEvent: \(event.name), isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType), \(cropTile.growthStage)", speaker: .dev)
						} else {
							MessageBox.message("tileType: \(tile.type.name), tileEvent: \(event.name), isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType)", speaker: .dev)
						}
						MessageBox.message("tileType: \(tile.type.name), tileEvent: \(event.name), isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType)", speaker: .dev)
					} else {
						MessageBox.message("tileType: \(tile.type.name), tileEvent: nil, isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType)", speaker: .dev)
					}
			#endif
			case .zero:
				Screen.clear()
				Screen.initialize()
				Screen.initializeBoxes()
			case .i:
				await Game.shared.setIsInInventoryBox(true)
				InventoryBox.sides()
			case .b:
				if await Game.shared.player.canBuild, MapBox.mapType != .mining {
					InventoryBox.resetSelectedBuildItemIndex
					await Game.shared.setIsBuilding(true)
					MapBox.sides()
					InventoryBox.inventoryBox()
				}
			case .W:
				MessageBox.lineUp()
			case .S:
				MessageBox.lineDown()
			#if DEBUG
				case .t:
					MessageBox.message("t", speaker: .dev)
					MapBox.mainMap.grid[MapBox.player.y][MapBox.player.x] = .init(type: .crop(crop: .init(type: .carrot)), isWalkable: true, event: .collectCrop)
					await Game.shared.addCrop(TilePosition(x: MapBox.player.x, y: MapBox.player.y))
			#endif
			default:
				#if DEBUG
					MessageBox.message("You pressed: \(key.rawValue)", speaker: .game)
				#else
					break
				#endif
		}
	}

	static func building(key: KeyboardKeys) async {
		switch key {
			case .b, .esc:
				await Game.shared.setIsBuilding(false)
				InventoryBox.showBuildHelp = false
				MapBox.mapBox()
				InventoryBox.inventoryBox()
			case .w where await Game.shared.config.wasdKeys, .up where await Game.shared.config.arrowKeys, .k where await Game.shared.config.vimKeys:
				MapBox.movePlayer(.up)
			case .a where await Game.shared.config.wasdKeys, .left where await Game.shared.config.arrowKeys, .h where await Game.shared.config.vimKeys:
				MapBox.movePlayer(.left)
			case .s where await Game.shared.config.wasdKeys, .down where await Game.shared.config.arrowKeys, .j where await Game.shared.config.vimKeys:
				MapBox.movePlayer(.down)
			case .d where await Game.shared.config.wasdKeys, .right where await Game.shared.config.arrowKeys, .l where await Game.shared.config.vimKeys:
				MapBox.movePlayer(.right)
			case .space, .enter:
				MapBox.build()
			case .e:
				MapBox.destroy()
			case .tab:
				InventoryBox.nextBuildItem()
			case .back_tab:
				InventoryBox.previousBuildItem()
			case .questionMark:
				InventoryBox.showBuildHelp.toggle()
			default:
				#if DEBUG
					MessageBox.message("You pressed: \(key.rawValue)", speaker: .game)
				#else
					break
				#endif
		}
	}

	static func inventory(key: KeyboardKeys) async {
		switch key {
			case .i, .esc:
				InventoryBox.showHelp = false
				await Game.shared.setIsInInventoryBox(false)
				InventoryBox.inventoryBox()
			case .up, .back_tab:
				InventoryBox.previousInventoryItem()
			case .down, .tab:
				InventoryBox.nextInventoryItem()
			case .questionMark:
				InventoryBox.showHelp.toggle()
			case .d:
				InventoryBox.destroyItem()
			default:
				#if DEBUG
					MessageBox.message("You pressed: \(key.rawValue)", speaker: .game)
				#else
					break
				#endif
		}
	}
}
