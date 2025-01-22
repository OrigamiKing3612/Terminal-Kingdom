struct MainMap: MapBoxMap {
	var grid: [[MapTile]]

	var player: Player {
		get { Game.player.position }
		set { Game.player.updatePlayerPositionToSave(x: newValue.x, y: newValue.y) }
	}

	private var hasFoundPlayerStart = false

	init() {
		self.grid = Game.map
	}

	var tilePlayerIsOn: MapTile {
		grid[player.y][player.x]
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
			Screen.print(x: MapBox.startX, y: MapBox.startY + screenY, rowString)
		}
	}

	mutating func movePlayer(_ direction: PlayerDirection) {
		let oldX = player.x
		let oldY = player.y

		Game.player.direction = direction

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
			StatusBox.position()
		}
	}

	mutating func map() {
		// TODO: could fix #2
		if !hasFoundPlayerStart {
			if let (startX, startY) = MapTile.findTilePosition(of: .playerStart, in: grid) {
				player.x = startX
				player.y = startY
			} else {
				print("Error: Could not find playerStart tile in the grid.")
			}
			hasFoundPlayerStart = true
		}

		let viewportWidth = MapBox.width
		let viewportHeight = MapBox.height
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
