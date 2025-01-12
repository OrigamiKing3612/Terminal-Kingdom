enum Keys {
	static func normal(key: KeyboardKeys) {
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
				MapBox.interactWithTile()
			case .l where MapBox.mapType == .mining:
				MapBox.mapType = .mine
				MapBox.buildingMap.player.x = 2
				MapBox.buildingMap.player.y = 2
				MapBox.mapBox()
			case .p:
				// TODO: move to status box
				switch MapBox.mapType {
					case .mainMap:
						let x = MapBox.player.x
						let y = MapBox.player.y
						MessageBox.message("x: \(x); y: \(y)", speaker: .game)
					case .mining:
						break
					default:
						let x = MapBox.buildingMap.player.x
						let y = MapBox.buildingMap.player.y
						MessageBox.message("x: \(x); y: \(y)", speaker: .game)
				}
			#if DEBUG
				case .o:
					let tile = MapBox.mapType.map.tilePlayerIsOn
					if let event = tile.event {
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
			default:
				break
		}
	}

	static func inventory(key: KeyboardKeys) {
		switch key {
			case .i, .esc:
				Game.isInInventoryBox = false
				InventoryBox.sides()
			case .up:
				InventoryBox.selectedInventoryIndex -= 1
			case .down:
				InventoryBox.selectedInventoryIndex += 1
			case .questionMark:
				InventoryBox.showHelp.toggle()
			case .d:
				InventoryBox.destroyItem()
			default:
				break
		}
	}
}
