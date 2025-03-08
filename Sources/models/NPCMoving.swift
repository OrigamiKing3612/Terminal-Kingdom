import Foundation

enum NPCMoving {
	struct Position: Equatable, Hashable {
		var x: Int
		var y: Int
	}

	static func move(target toTilePosition: TilePosition, current: TilePosition) async -> Position {
		await MessageBox.message("  Move", speaker: .dev)
		let targetPosition = Position(x: toTilePosition.x, y: toTilePosition.y)
		let currentPosition = Position(x: current.x, y: current.y)
		let map = await MapBox.mapType.map.grid

		let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)] // Up, Down, Right, Left
		var openSet: [(Position, Int)] = [(currentPosition, 0)] // (Position, cost)
		var cameFrom: [Position: Position] = [:]
		var gScore: [Position: Int] = [currentPosition: 0]

		while !openSet.isEmpty {
			openSet.sort { $0.1 < $1.1 } // Sort by cost
			let (current, _) = openSet.removeFirst()

			if current == targetPosition { // Reached the goal
				var node: Position? = targetPosition
				var path: [Position] = []

				while let n = node, n != currentPosition {
					path.append(n)
					node = cameFrom[n]
				}
				return path.reversed().first ?? currentPosition // Return next step
			}

			for (dx, dy) in directions {
				let neighbor = Position(x: current.x + dx, y: current.y + dy)

				if neighbor.x < 0 || neighbor.y < 0 || neighbor.x >= map[0].count || neighbor.y >= map.count {
					continue
				}

				if case .building = map[neighbor.y][neighbor.x].type as! MapTileType {
					continue
				}

				let newGScore = gScore[current]! + 1
				if newGScore < (gScore[neighbor] ?? Int.max) {
					cameFrom[neighbor] = current
					gScore[neighbor] = newGScore
					openSet.append((neighbor, newGScore))
				}
			}
		}

		return currentPosition
	}
	// func moveAlong(path: [Position], currentPosition: Position) {
	// 	if let nextPosition = path.first {
	// 		currentPosition = nextPosition
	// 	}
	// }
	// let grid = await MapBox.mapType.map.grid
	// // guard let tile = grid[from.y][from.x] as? MapTile else { continue }
	//
	// // let npcType = tile.type
	//
	// // if case let .npc(tile: npc) = npcType {
	// let changeDirectionChance = Int.random(in: 1 ... 100)
	// var newDirection = npc.lastDirection
	// if changeDirectionChance <= 20 {
	// 	newDirection = PlayerDirection.allCases.randomElement()!
	// }
	//
	// var newX = from.x
	// var newY = from.y
	//
	// switch newDirection {
	// 	case .up: newY -= 1
	// 	case .down: newY += 1
	// 	case .left: newX -= 1
	// 	case .right: newX += 1
	// }
	//
	// if newX >= 0, newX < grid[0].count, newY >= 0, newY < grid.count, grid[newY][newX].isWalkable {
	// 	let newPosition = NPCPosition(oldX: newX, oldY: newY, mapType: npcPosition.mapType, oldTile: tile)
	//
	// 	await Game.shared.updateNPC(oldPosition: npcPosition, newPosition: newPosition)
	//
	// 	// Put back old
	// 	await MapBox.setMapGridTile(x: npcPosition.oldX, y: npcPosition.oldY, tile: npcPosition.oldTile, mapType: npcPosition.mapType)
	//
	// 	// Put new
	// 	await MapBox.setMapGridTile(x: newX, y: newY, tile: .init(type: .npc(tile: npc), isWalkable: true, event: .talkToNPC, biome: tile.biome), mapType: npcPosition.mapType)
	//
	// 	await MapBox.mapBox() //! TODO: Improve this
	// 	// }
	// }
}
