struct BuildingMap: MapBoxMap {
	var grid: [[MapTile]]
	// {
	// didSet {
	// 	if case let .custom(map: map) = mapType {
	// 		map.updateGrid(grid)
	// 	}
	// }
	// }

	var player: Player = .init(x: 1, y: 1)

	var tilePlayerIsOn: MapTile {
		grid[player.y][player.x]
	}

	let mapType: MapType

	init(_ mapType: MapType) {
		self.mapType = mapType
		if case let .custom(map: customMap) = mapType {
			grid = customMap.grid
		} else {
			grid = StaticMaps.buildingMap(for: StaticMaps.mapTypeToBuilding(mapType: mapType))
		}

		// Coordinates for inside the building
		if Game.player.position.x == 55, Game.player.position.y == 23 {
			// Start player in correct spot on start
			player.x = 55
			player.y = 23
		} else if case let .castle(side: side) = mapType {
			switch side {
				case .top:
					player.x = 64
					player.y = 1
				case .bottom:
					player.x = 65
					player.y = 53
				case .right:
					player.x = 129
					player.y = 27
				case .left:
					player.x = 1
					player.y = 27
			}
		} else if case let .farm(type: type) = mapType {
			switch type {
				case .main:
					findPayerStart()
				case .farm_area:
					player.x = 9
					player.y = 1
			}
		} else {
			findPayerStart()
		}
	}

	private mutating func findPayerStart() {
		if let (startX, startY) = MapTile.findTilePosition(of: .playerStart, in: grid) {
			player.x = startX
			player.y = startY
		} else {
			print("Error: Could not find playerStart tile in the building grid.")
		}
	}

	mutating func map() {
		let viewportWidth = MapBox.width + 1
		let viewportHeight = MapBox.height
		render(playerX: player.x, playerY: player.y, viewportWidth: viewportWidth, viewportHeight: viewportHeight)
	}

	func isWalkable(x: Int, y: Int) -> Bool {
		guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
		return grid[y][x].isWalkable
	}

	func render(playerX: Int, playerY: Int, viewportWidth: Int, viewportHeight: Int) {
		let halfViewportWidth = viewportWidth / 2
		let halfViewportHeight = viewportHeight / 2

		let startX = max(0, playerX - halfViewportWidth)
		let startY = max(0, playerY - halfViewportHeight)

		let endX = min(grid[0].count, startX + viewportWidth)
		let endY = min(grid.count, startY + viewportHeight)

		for (screenY, mapY) in (startY ..< endY).enumerated() {
			var rowString = ""
			for mapX in startX ..< endX {
				if mapX == playerX, mapY == playerY {
					rowString += MapTileType.player.render()
				} else {
					rowString += grid[mapY][mapX].type.render()
				}
			}
			Screen.print(x: MapBox.startX, y: MapBox.startY + screenY, rowString)
		}
	}

	mutating func movePlayer(_ direction: Direction) {
		let oldX = player.x
		let oldY = player.y

		switch direction {
			case .up where isWalkable(x: player.x, y: player.y - 1):
				player.y -= 1
			case .down where isWalkable(x: player.x, y: player.y + 1):
				player.y += 1
			case .left where isWalkable(x: player.x - 1, y: player.y):
				player.x -= 1
			case .right where isWalkable(x: player.x + 1, y: player.y):
				player.x += 1
			default:
				break
		}

		if oldX != player.x || oldY != player.y {
			map()
		}
	}

	func interactWithTile() {
		let tile = grid[player.y][player.x]
		if tile.isInteractable {
			if let event = tile.event {
				MapTileEvent.trigger(event: event)
			}
		} else {
			MessageBox.message("There is nothing to do here.", speaker: .game)
		}
	}

	mutating func updateTile(newTile: MapTile) {
		grid[player.y][player.x] = newTile
	}

	mutating func build() {
		MapBuilding.build(grid: &grid, x: player.x, y: player.y)
	}

	mutating func destroy() {
		MapBuilding.destory(grid: &grid, x: player.x, y: player.y)
	}
}
