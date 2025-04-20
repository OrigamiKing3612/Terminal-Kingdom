import Foundation

extension NPCTile {
	// static func move(position: NPCPosition) async {
	// 	// Logger.debug("\(#function) \(#file):\(#line): Moving NPC from \(position.x), \(position.y)")
	// 	let npcTile = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile
	// 	if case let .npc(tile: tile) = npcTile.type, let positionToWalkTo = await tile.npc.positionToWalkTo {
	// 		// Reached the destination
	// 		if positionToWalkTo == .init(x: position.x, y: position.y, mapType: position.mapType) {
	// 			await Game.shared.removeNPC(position)
	// 			if case let .door(doorTile) = position.oldTile.type {
	// 				if case let .custom(mapID, _) = doorTile.type {
	// 					// TODO: fix this when multidoors in custom maps
	// 					guard let mapID else { return }
	// 					guard let grid = await Game.shared.maps.customMaps[mapID]?.grid else { return }
	//
	// 					for (yIndex, y) in grid.enumerated() {
	// 						if let xIndex = y.firstIndex(where: { if case .door = $0.type { true } else { false }}) {
	// 							// Restore the door tile
	// 							await MapBox.updateTile(newTile: MapTile(
	// 								type: .door(tile: doorTile),
	// 								isWalkable: npcTile.isWalkable,
	// 								event: npcTile.event,
	// 								biome: npcTile.biome
	// 							), x: position.x, y: position.y)
	// 							var doorPosition: DoorPosition = .bottom
	// 							if yIndex == 0 {
	// 								doorPosition = .top
	// 							} else if yIndex == grid.count - 1 {
	// 								doorPosition = .bottom
	// 							} else if xIndex == 0 {
	// 								doorPosition = .left
	// 							} else if xIndex == grid[yIndex].count - 1 {
	// 								doorPosition = .right
	// 							}
	// 							let npcX: Int
	// 							let npcY: Int
	// 							switch doorPosition {
	// 								case .left:
	// 									npcX = xIndex + 1
	// 									npcY = yIndex + 1
	// 								case .right:
	// 									npcX = xIndex - 1
	// 									npcY = yIndex - 1
	// 								case .top:
	// 									npcX = xIndex - 1
	// 									npcY = yIndex + 1
	// 								case .bottom:
	// 									npcX = xIndex + 1
	// 									npcY = yIndex - 1
	// 							}
	//
	// 							var newGrid = grid
	// 							await Game.shared.npcs.removeNPCPosition(npcID: tile.npcID)
	// 							newGrid[npcY][npcX] = MapTile(
	// 								type: .npc(tile: .init(id: tile.id, npcID: tile.npcID)),
	// 								isWalkable: npcTile.isWalkable,
	// 								event: npcTile.event,
	// 								biome: npcTile.biome
	// 							)
	// 							await Game.shared.maps.updateCustomMap(id: mapID, with: newGrid)
	// 							break
	// 						}
	// 					}
	//
	// 				} else {}
	// 				// put npcID in the custom map
	// 				return
	// 			} else {
	// 				await Game.shared.npcs.removeNPCPosition(npcID: tile.npcID)
	// 				await MapBox.updateTile(newTile: MapTile(
	// 					type: .npc(tile: .init(id: tile.id, npcID: tile.npcID)),
	// 					isWalkable: npcTile.isWalkable,
	// 					event: npcTile.event,
	// 					biome: npcTile.biome
	// 				), x: position.x, y: position.y)
	// 				return
	// 			}
	// 		}
	// 		let newNpcPosition = await NPCMoving.move(
	// 			target: positionToWalkTo,
	// 			current: .init(x: position.x, y: position.y, mapType: position.mapType)
	// 		)
	// 		guard await MapBox.mapType == position.mapType else { return }
	// 		let currentTile = await MapBox.mapType.map.grid[newNpcPosition.y][newNpcPosition.x] as! MapTile
	//
	// 		let newPosition = NPCPosition(
	// 			x: newNpcPosition.x,
	// 			y: newNpcPosition.y,
	// 			mapType: position.mapType,
	// 			oldTile: currentTile
	// 		)
	//
	// 		await withTaskGroup { group in
	// 			group.addTask {
	// 				// Restore old tile
	// 				await MapBox.setMapGridTile(
	// 					x: position.x,
	// 					y: position.y,
	// 					tile: position.oldTile,
	// 					mapType: position.mapType
	// 				)
	// 			}
	//
	// 			group.addTask {
	// 				// Update new tile to NPC
	// 				await MapBox.setMapGridTile(
	// 					x: newNpcPosition.x,
	// 					y: newNpcPosition.y,
	// 					tile: MapTile(
	// 						type: .npc(tile: tile),
	// 						isWalkable: npcTile.isWalkable,
	// 						event: npcTile.event,
	// 						biome: npcTile.biome
	// 					),
	// 					mapType: position.mapType
	// 				)
	// 			}
	//
	// 			group.addTask {
	// 				await Game.shared.updateNPC(oldPosition: position, newPosition: newPosition)
	// 			}
	//
	// 			group.addTask {
	// 				await MapBox.updateTwoTiles(x1: newNpcPosition.x, y1: newNpcPosition.y, x2: position.x, y2: position.y)
	// 			}
	// 		}
	// 	}
	// }

	static func move(position: NPCMovingPosition) async {
		let tileNPCisOn = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile
		if case let .npc(tile: npcTile) = tileNPCisOn.type, let positionToWalkTo = await npcTile.npc.positionToWalkTo {
			if await isDestinationInCurrentMap(destination: positionToWalkTo, mapType: position.mapType) {
				await moveToDestination(currentPosition: position, destination: positionToWalkTo, npcTile: npcTile, tileNPCisOn: tileNPCisOn)
			} else {
				await moveToDoor(position: position, npcTile: npcTile)
			}
		}
	}

	static func isDestinationInCurrentMap(destination: NPCPosition, mapType: MapType) async -> Bool {
		assert(mapType != .mining, "NPCs should not be moving in the mining map")
		let x = await destination.x < mapType.grid[0].count
		let y = await destination.y < mapType.grid.count
		return destination.mapType == mapType && destination.x > 0 && x && destination.y >= 0 && y
	}

	static func moveToDestination(currentPosition: NPCMovingPosition, destination: NPCPosition, npcTile: NPCTile, tileNPCisOn: MapTile) async {
		guard await isDestinationInCurrentMap(destination: destination, mapType: currentPosition.mapType) else { return }

		let currentTile = await MapBox.mapType.map.grid[currentPosition.y][currentPosition.x] as! MapTile
		let destinationTile = await MapBox.mapType.map.grid[destination.y][destination.x] as! MapTile

		// Check if destination is valid (e.g., not a door, walkable, etc.)
		guard destinationTile.isWalkable else { return }

		// Move the NPC on the map
		await MapBox.setMapGridTile(x: destination.x, y: destination.y, tile: .init(type: .npc(tile: npcTile), biome: tileNPCisOn.biome), mapType: currentPosition.mapType)
		await MapBox.setMapGridTile(x: currentPosition.x, y: currentPosition.y, tile: destinationTile, mapType: currentPosition.mapType)

		// Update NPC position
		let currentMovingTile = NPCMovingPosition(x: currentPosition.x, y: currentPosition.y, mapType: currentPosition.mapType, oldTile: currentTile)
		let destinationMovingTile = NPCMovingPosition(x: destination.x, y: destination.y, mapType: destination.mapType, oldTile: destinationTile)
		await Game.shared.updateNPC(oldPosition: currentMovingTile, newPosition: destinationMovingTile)
	}

	static func moveToDoor(position: NPCMovingPosition, npcTile: NPCTile) async {
		guard let doorTile = await findDoorTileForPosition(position) else {
			Logger.error("No door tile found for position \(position)", code: .noDoorTile)
		}
		await switchMaps(from: position, doorTile: doorTile, npcTile: npcTile)
	}

	static func findDoorTileForPosition(_ position: NPCMovingPosition) async -> DoorTile? {
		let tile = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile
		if case let .door(tile: doorTile) = tile.type {
			return doorTile
		}
		return nil
	}
}

enum NPCMoving {
	struct Position: Equatable, Hashable {
		var x: Int
		var y: Int
	}

	static func move(target toTilePosition: TilePosition, current: TilePosition) async -> Position {
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
}
