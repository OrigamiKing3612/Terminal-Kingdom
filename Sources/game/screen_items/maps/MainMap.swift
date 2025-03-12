struct MainMap: MapBoxMap {
	var grid: [[MapTile]]

	var player: Player {
		get async { await Game.shared.player.position }
	}

	private var hasFoundPlayerStart = false

	private init() {
		self.grid = []
		print("This shouldn't be used")
	}

	init() async {
		self.grid = await Game.shared.map
	}

	var tilePlayerIsOn: MapTile {
		get async {
			await grid[player.y][player.x]
		}
	}

	func isWalkable(x: Int, y: Int) async -> Bool {
		guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
		if grid[y][x].type == .building(tile: .init(isPlacedByPlayer: true)) {
			return await Game.shared.isBuilding
		}
		return grid[y][x].isWalkable
	}

	func render(playerX: Int, playerY: Int, viewportWidth: Int, viewportHeight: Int) async {
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
					await rowString += MapTileType.player.render()
				} else {
					await rowString += grid[mapY][mapX].type.render()
				}
			}
			Screen.print(x: MapBox.startX, y: MapBox.startY + screenY, rowString)
		}
	}

	mutating func movePlayer(_ direction: PlayerDirection) async {
		let oldX = await player.x
		let oldY = await player.y
		var x: Int { get async { await player.x } }
		var y: Int { get async { await player.y } }

		await Game.shared.player.setDirection(direction)

		switch direction {
			case .up where await isWalkable(x: x, y: y - 1):
				await Game.shared.player.setPlayerPosition(x: player.x, y: player.y - 1)
			case .down where await isWalkable(x: x, y: y + 1):
				await Game.shared.player.setPlayerPosition(x: player.x, y: player.y + 1)
			case .left where await isWalkable(x: x - 1, y: y):
				await Game.shared.player.setPlayerPosition(x: player.x - 1, y: player.y)
			case .right where await isWalkable(x: x + 1, y: y):
				await Game.shared.player.setPlayerPosition(x: player.x + 1, y: player.y)
			default:
				break
		}

		await tilePlayerIsOn.type.specialAction(direction: direction, grid: grid)
		let a = await oldX != x
		let b = await oldY != y
		if a || b {
			await map()
			await StatusBox.position()
		}
	}

	mutating func map() async {
		// TODO: could fix #2
		if !hasFoundPlayerStart {
			if let (startX, startY) = MapTile.findTilePosition(of: .playerStart, in: grid) {
				await Game.shared.player.setPlayerPosition(x: startX, y: startY)
			} else {
				print("Error: Could not find playerStart tile in the grid.")
			}
			hasFoundPlayerStart = true
		}

		let viewportWidth = MapBox.width
		let viewportHeight = MapBox.height
		await render(playerX: player.x, playerY: player.y, viewportWidth: viewportWidth, viewportHeight: viewportHeight)
	}

	// TODO: make this one tile and use it twice. Also update existing full redraws
	mutating func updateTwoTiles(x1: Int, y1: Int, x2: Int, y2: Int) async {
		// let viewportWidth = MapBox.width
		// let viewportHeight = MapBox.height
		// let playerX = await player.x
		// let playerY = await player.y
		//
		// func withinViewport(_ x: Int, _ y: Int) -> Bool {
		// 	x >= playerX - viewportWidth / 2 && x <= playerX + viewportWidth / 2 && y >= playerY - viewportHeight / 2 && y <= playerY + viewportHeight / 2
		// }
		//
		// if withinViewport(x1, y1) {
		// 	await Screen.print(x: x1, y: y1, grid[y1][x1].type.render())
		// }
		// if withinViewport(x2, y2) {
		// 	await Screen.print(x: x2, y: y2, grid[y2][x2].type.render())
		// }
		let viewportWidth = MapBox.width
		let viewportHeight = MapBox.height
		let startX = await player.x - viewportWidth / 2
		let startY = await player.y - viewportHeight / 2

		if x1 >= startX, x1 < startX + viewportWidth, y1 >= startY, y1 < startY + viewportHeight {
			let screenX1 = x1 - startX + MapBox.startX
			let screenY1 = y1 - startY + MapBox.startY
			await Screen.print(x: screenX1, y: screenY1, grid[y1][x1].type.render())
		}

		if x2 >= startX, x2 < startX + viewportWidth, y2 >= startY, y2 < startY + viewportHeight {
			let screenX2 = x2 - startX + MapBox.startX
			let screenY2 = y2 - startY + MapBox.startY
			await Screen.print(x: screenX2, y: screenY2, grid[y2][x2].type.render())
		}
	}

	func interactWithTile() async {
		let tile = await grid[player.y][player.x]
		if tile.isInteractable {
			if let event = tile.event {
				await MapTileEvent.trigger(event: event)
			}
		} else {
			await MessageBox.message("There is nothing to do here.", speaker: .game)
		}
	}

	mutating func updateTile(newTile: MapTile) async {
		await grid[player.y][player.x] = newTile
	}

	mutating func updateTile(newTile: MapTile, x: Int, y: Int) async {
		grid[y][x] = newTile
	}

	mutating func build() async {
		await MapBuilding.build(grid: &grid, x: player.x, y: player.y)
	}

	mutating func destroy() async {
		await MapBuilding.destory(grid: &grid, x: player.x, y: player.y)
	}
}
