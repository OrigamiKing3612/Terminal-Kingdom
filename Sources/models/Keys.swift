enum Keys {
	static func normal(key: KeyboardKeys) async {
		switch key {
			case .q:
				endProgram()
			case .w where await Game.shared.config.wasdKeys, .up where await Game.shared.config.arrowKeys, .k where await Game.shared.config.vimKeys:
				await MapBox.movePlayer(.up)
			case .a where await Game.shared.config.wasdKeys, .left where await Game.shared.config.arrowKeys, .h where await Game.shared.config.vimKeys:
				await MapBox.movePlayer(.left)
			case .s where await Game.shared.config.wasdKeys, .down where await Game.shared.config.arrowKeys, .j where await Game.shared.config.vimKeys:
				await MapBox.movePlayer(.down)
			case .d where await Game.shared.config.wasdKeys, .right where await Game.shared.config.arrowKeys, .l where await Game.shared.config.vimKeys:
				await MapBox.movePlayer(.right)
			case .space, .enter:
				await MapBox.interactWithTile()
			case .L where await MapBox.mapType == .mining:
				await MapBox.setMapType(.mine)
				await MapBox.setBuildingMapPlayer(x: 2, y: 2)
				await MapBox.mapBox()
			#if DEBUG
				case .o:
					let tile = await MapBox.mapType.map.tilePlayerIsOn as! MapTile
					if let event = tile.event {
						if case let .crop(crop: cropTile) = tile.type {
							await MessageBox.message("tileType: \(tile.type.name), tileEvent: \(event.name), isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType), \(cropTile.growthStage)", speaker: .dev)
						} else {
							await MessageBox.message("tileType: \(tile.type.name), tileEvent: \(event.name), isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType)", speaker: .dev)
						}
						await MessageBox.message("tileType: \(tile.type.name), tileEvent: \(event.name), isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType)", speaker: .dev)
					} else {
						await MessageBox.message("tileType: \(tile.type.name), tileEvent: nil, isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType)", speaker: .dev)
					}
			#endif
			case .zero:
				Screen.clear()
				Screen.initialize()
				await Screen.initializeBoxes()
			case .i:
				await Game.shared.setIsInInventoryBox(true)
				await InventoryBox.sides()
			case .b:
				if await Game.shared.player.canBuild, await MapBox.mapType != .mining {
					InventoryBox.resetSelectedBuildItemIndex
					await Game.shared.setIsBuilding(true)
					await MapBox.sides()
					await InventoryBox.inventoryBox()
				}
			case .W:
				await MessageBox.lineUp()
			case .S:
				await MessageBox.lineDown()
			#if DEBUG
				case .t:
					await MessageBox.message("t", speaker: .dev)
					await MapBox.setMainMapGridTile(tile: .init(type: .crop(crop: .init(type: .carrot)), isWalkable: true, event: .collectCrop))
					await Game.shared.addCrop(TilePosition(x: MapBox.player.x, y: MapBox.player.y))
			#endif
			default:
				#if DEBUG
					await MessageBox.message("You pressed: \(key.rawValue)", speaker: .game)
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
				await MapBox.mapBox()
				await InventoryBox.inventoryBox()
			case .w where await Game.shared.config.wasdKeys, .up where await Game.shared.config.arrowKeys, .k where await Game.shared.config.vimKeys:
				await MapBox.movePlayer(.up)
			case .a where await Game.shared.config.wasdKeys, .left where await Game.shared.config.arrowKeys, .h where await Game.shared.config.vimKeys:
				await MapBox.movePlayer(.left)
			case .s where await Game.shared.config.wasdKeys, .down where await Game.shared.config.arrowKeys, .j where await Game.shared.config.vimKeys:
				await MapBox.movePlayer(.down)
			case .d where await Game.shared.config.wasdKeys, .right where await Game.shared.config.arrowKeys, .l where await Game.shared.config.vimKeys:
				await MapBox.movePlayer(.right)
			case .space, .enter:
				await MapBox.build()
			case .e:
				await MapBox.destroy()
			case .tab:
				InventoryBox.nextBuildItem()
			case .back_tab:
				InventoryBox.previousBuildItem()
			case .questionMark:
				InventoryBox.showBuildHelp.toggle()
			default:
				#if DEBUG
					await await MessageBox.message("You pressed: \(key.rawValue)", speaker: .game)
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
				await InventoryBox.inventoryBox()
			case .up, .back_tab:
				InventoryBox.previousInventoryItem()
			case .down, .tab:
				InventoryBox.nextInventoryItem()
			case .questionMark:
				InventoryBox.showHelp.toggle()
			case .d:
				await InventoryBox.destroyItem()
			default:
				#if DEBUG
					await await MessageBox.message("You pressed: \(key.rawValue)", speaker: .game)
				#else
					break
				#endif
		}
	}
}
