enum Keys {
	static func normal(key: KeyboardKeys) async {
		switch key {
			case .q:
				endProgram()
			case .w where Game.config.wasdKeys, .up where Game.config.arrowKeys, .k where Game.config.vimKeys:
				MapBox.movePlayer(.up)
			case .a where Game.config.wasdKeys, .left where Game.config.arrowKeys, .h where Game.config.vimKeys:
				MapBox.movePlayer(.left)
			case .s where Game.config.wasdKeys, .down where Game.config.arrowKeys, .j where Game.config.vimKeys:
				MapBox.movePlayer(.down)
			case .d where Game.config.wasdKeys, .right where Game.config.arrowKeys, .l where Game.config.vimKeys:
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
				Game.isInInventoryBox = true
				InventoryBox.sides()
			case .b:
				if Game.player.canBuild, MapBox.mapType != .mining {
					InventoryBox.resetSelectedBuildItemIndex
					Game.isBuilding = true
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
					Game.crops.insert(TilePosition(x: MapBox.player.x, y: MapBox.player.y))
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
				Game.isBuilding = false
				InventoryBox.showBuildHelp = false
				MapBox.mapBox()
				InventoryBox.inventoryBox()
			case .w where Game.config.wasdKeys, .up where Game.config.arrowKeys, .k where Game.config.vimKeys:
				MapBox.movePlayer(.up)
			case .a where Game.config.wasdKeys, .left where Game.config.arrowKeys, .h where Game.config.vimKeys:
				MapBox.movePlayer(.left)
			case .s where Game.config.wasdKeys, .down where Game.config.arrowKeys, .j where Game.config.vimKeys:
				MapBox.movePlayer(.down)
			case .d where Game.config.wasdKeys, .right where Game.config.arrowKeys, .l where Game.config.vimKeys:
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
				Game.isInInventoryBox = false
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
