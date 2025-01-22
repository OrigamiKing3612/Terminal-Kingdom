struct MineMap: MapBoxMap {
	var grid: [[MineTile]]

	var player: Player = .init(x: 1, y: 1)

	var tilePlayerIsOn: MineTile {
		grid[player.y][player.x]
	}

	init() {
		self.grid = MineMap.createGrid()

		let middleX = grid[0].count / 2
		//        let middleY = self.grid.count / 2

		grid[0][middleX] = .init(type: .playerStart, isWalkable: true)
		grid[0][middleX + 1] = .init(type: .plain, isWalkable: true)
		grid[0][middleX - 1] = .init(type: .plain, isWalkable: true)

		if let (startX, startY) = MineTile.findTilePosition(of: .playerStart, in: grid) {
			player.x = startX
			player.y = startY
		} else {
			print("Error: Could not find playerStart tile in the mine grid.")
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

	func isInBounds(x: Int, y: Int) -> Bool {
		x >= 0 && y >= 0 && y < grid.count && x < grid[y].count
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
					rowString += MineTileType.player.render(grid: grid, tileX: mapX, tileY: mapY)
				} else {
					rowString += grid[mapY][mapX].type.render(grid: grid, tileX: mapX, tileY: mapY)
				}
			}
			Screen.print(x: MapBox.startX, y: MapBox.startY + screenY, rowString)
		}
	}

	mutating func movePlayer(_ direction: PlayerDirection) {
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
			// mine
			case .up where Game.player.hasPickaxe() && isInBounds(x: player.x, y: player.y - 1):
				MineMap.givePlayerTile(tile: grid[player.y - 1][player.x])
				grid[player.y - 1][player.x] = .init(type: .plain, isWalkable: true)
				Game.player.removeDurability(of: .pickaxe)
				player.y -= 1
			case .down where Game.player.hasPickaxe() && isInBounds(x: player.x, y: player.y + 1):
				MineMap.givePlayerTile(tile: grid[player.y + 1][player.x])
				grid[player.y + 1][player.x] = .init(type: .plain, isWalkable: true)
				Game.player.removeDurability(of: .pickaxe)
				player.y += 1
			case .left where Game.player.hasPickaxe() && isInBounds(x: player.x - 1, y: player.y):
				MineMap.givePlayerTile(tile: grid[player.y][player.x - 1])
				grid[player.y][player.x - 1] = .init(type: .plain, isWalkable: true)
				Game.player.removeDurability(of: .pickaxe)
				player.x -= 1
			case .right where Game.player.hasPickaxe() && isInBounds(x: player.x + 1, y: player.y):
				MineMap.givePlayerTile(tile: grid[player.y][player.x + 1])
				grid[player.y][player.x + 1] = .init(type: .plain, isWalkable: true)
				Game.player.removeDurability(of: .pickaxe)
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
				MineTileEvent.trigger(event: event)
			}
		} else {
			MessageBox.message("There is nothing to do here.", speaker: .game)
		}
	}

	static func givePlayerTile(tile: MineTile) {
		var itemTypeToGive: ItemType?
		switch tile.type {
			case .coal: itemTypeToGive = .coal
			case .iron: itemTypeToGive = .iron
			case .stone: itemTypeToGive = .stone
			case .clay: itemTypeToGive = .clay
			case .gold: itemTypeToGive = .gold
			default: break
		}
		if let itemTypeToGive {
			_ = Game.player.collect(item: .init(type: itemTypeToGive))
		}
	}

	static func createGrid() -> [[MineTile]] {
		switch Game.player.stats.mineLevel {
			case .one:
				MineMapLevelGrids.createGridLevel1()
			case .two:
				MineMapLevelGrids.createGridLevel2()
			case .three:
				MineMapLevelGrids.createGridLevel3()
		}
	}
}

enum MineMapLevelGrids {
	private static func createGrid(tiles: (_ randomValue: Int) -> MineTile) -> [[MineTile]] {
		Array(repeating: [], count: 2 * MapBox.height).map { _ in
			(0 ..< (2 * MapBox.width)).map { _ in
				let randomValue = Int.random(in: 1 ... 100)
				return tiles(randomValue)
			}
		}
	}

	static func createGridLevel1() -> [[MineTile]] {
		createGrid { randomValue in
			if randomValue <= 85 {
				MineTile(type: .clay)
			} else {
				MineTile(type: .stone)
			}
		}
	}

	static func createGridLevel2() -> [[MineTile]] {
		createGrid { randomValue in
			if randomValue <= 10 {
				MineTile(type: .clay)
			} else if randomValue <= 70 {
				MineTile(type: .stone)
			} else if randomValue <= 85 {
				MineTile(type: .coal)
			} else {
				MineTile(type: .iron)
			}
		}
	}

	static func createGridLevel3() -> [[MineTile]] {
		createGrid { randomValue in
			if randomValue <= 5 {
				MineTile(type: .gold)
			} else if randomValue <= 10 {
				MineTile(type: .clay)
			} else if randomValue <= 70 {
				MineTile(type: .stone)
			} else if randomValue <= 85 {
				MineTile(type: .coal)
			} else {
				MineTile(type: .iron)
			}
		}
	}
}
