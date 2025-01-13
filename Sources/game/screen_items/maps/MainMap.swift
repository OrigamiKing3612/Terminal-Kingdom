struct MainMap: MapBoxMap {
	var grid: [[MapTile]]
	var width: Int
	var height: Int

	var player: Player {
		get { Game.player.position }
		set { Game.player.updatePlayerPositionToSave(x: newValue.x, y: newValue.y) }
	}

	private var hasUpdatedDims = false

	init() {
		grid = Game.map
		width = grid[0].count + 1
		height = grid.count + 1
	}

	var tilePlayerIsOn: MapTile {
		grid[player.y][player.x]
	}

	mutating func updateDimensions(width: Int, height: Int) {
		self.width = width
		self.height = height
	}

	func isWalkable(x: Int, y: Int) -> Bool {
		guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
		if grid[y][x].type == .building(tile: .init(isPlacedByPlayer: true)) {
			return Game.isBuilding
		}
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
			Screen.print(x: MapBox.q1StartX + 1, y: MapBox.q1StartY + 1 + screenY, rowString)
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

		tilePlayerIsOn.type.specialAction(direction: direction, player: &player, grid: grid)

		if oldX != player.x || oldY != player.y {
			map()
		}
	}

	mutating func map() {
		if !hasUpdatedDims {
			updateDimensions(width: MapBox.q1Width, height: MapBox.q1Height)
			if let (startX, startY) = MapTile.findTilePosition(of: .playerStart, in: grid) {
				player.x = startX
				player.y = startY
			} else {
				print("Error: Could not find playerStart tile in the grid.")
			}
			hasUpdatedDims = true
		}

		let viewportWidth = MapBox.q1Width + 1
		let viewportHeight = MapBox.q1Height
		render(playerX: player.x, playerY: player.y, viewportWidth: viewportWidth, viewportHeight: viewportHeight)
	}

	mutating func setPlayerPosition(_ position: (x: Int, y: Int)) {
		player.x = position.x
		player.y = position.y
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

	mutating func build() {
		if case let .building(tile: buildingTile) = grid[player.y][player.x].type {
			if buildingTile.isPlacedByPlayer {
				grid[player.y][player.x] = MapTile(type: .plain)
				_ = Game.player.collect(item: .init(type: .lumber), count: 4)
			} else {
				MessageBox.message("You can't remove this building.", speaker: .game)
			}
		}
		if grid[player.y][player.x].type != .plain {
			MessageBox.message("You can't build here.", speaker: .game)
			return
		}
		if Game.player.has(item: .lumber, count: 5) {
			grid[player.y][player.x] = MapTile(type: .building(tile: .init(isPlacedByPlayer: true)))
			Game.player.removeItem(item: .lumber, count: 5)
		} else {
			MessageBox.message("You need 5 lumber to build a building.", speaker: .game)
		}
	}

	mutating func updateTile(newTile: MapTile) {
		grid[player.y][player.x] = newTile
	}
}
