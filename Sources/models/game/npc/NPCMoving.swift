import Foundation

extension NPCTile {
	static func move(position: NPCMovingPosition) async {
		// Logger.debug("\(#function) \(#file):\(#line): Moving NPC from \(position.x), \(position.y)")
		let tileNPCisOn = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile
		if case let .npc(tile: tile) = tileNPCisOn.type, let positionToWalkTo = await tile.npc.positionToWalkTo {
			// Reached the destination
			if hasReachedDestination(position, target: positionToWalkTo) {
				await reachedDestination(position: position, tileNPCisOn: tileNPCisOn, tile: tile)
			}
			let newNpcPosition = await NPCMoving.move(
				target: positionToWalkTo,
				current: .init(x: position.x, y: position.y, mapType: position.mapType)
			)
			guard await MapBox.mapType == position.mapType else { return }
			await updateMapForNPCMove(from: position, to: newNpcPosition, tile: tile, npcTile: tileNPCisOn)
		}
	}

	private static func reachedDestination(position: NPCMovingPosition, tileNPCisOn: MapTile, tile: NPCTile) async {
		await Game.shared.removeNPC(position)
		if case let .door(doorTile) = position.oldTile.type {
			if case let .custom(mapID, _) = doorTile.type {
				// TODO: fix this when multidoors in custom maps
				guard let mapID else { return }
				guard let grid = await Game.shared.maps.customMaps[mapID]?.grid else { return }

				for (yIndex, y) in grid.enumerated() {
					if let xIndex = y.firstIndex(where: { if case .door = $0.type { true } else { false }}) {
						// Restore the door tile
						await MapBox.updateTile(newTile: MapTile(
							type: .door(tile: doorTile),
							isWalkable: tileNPCisOn.isWalkable,
							event: tileNPCisOn.event,
							biome: tileNPCisOn.biome
						), x: position.x, y: position.y)
						var doorPosition: DoorPosition = .bottom
						if yIndex == 0 {
							doorPosition = .top
						} else if yIndex == grid.count - 1 {
							doorPosition = .bottom
						} else if xIndex == 0 {
							doorPosition = .left
						} else if xIndex == grid[yIndex].count - 1 {
							doorPosition = .right
						}
						let npcX: Int
						let npcY: Int
						switch doorPosition {
							case .left:
								npcX = xIndex + 1
								npcY = yIndex + 1
							case .right:
								npcX = xIndex - 1
								npcY = yIndex - 1
							case .top:
								npcX = xIndex - 1
								npcY = yIndex + 1
							case .bottom:
								npcX = xIndex + 1
								npcY = yIndex - 1
						}

						var newGrid = grid
						await Game.shared.npcs.removeNPCPosition(npcID: tile.npcID)
						newGrid[npcY][npcX] = MapTile(
							type: .npc(tile: .init(id: tile.id, npcID: tile.npcID)),
							isWalkable: tileNPCisOn.isWalkable,
							event: tileNPCisOn.event,
							biome: tileNPCisOn.biome
						)
						await Game.shared.maps.updateCustomMap(id: mapID, with: newGrid)
						break
					}
				}

			} else {}
			// put npcID in the custom map
			return
		} else {
			await Game.shared.npcs.removeNPCPosition(npcID: tile.npcID)
			await MapBox.updateTile(newTile: MapTile(
				type: .npc(tile: .init(id: tile.id, npcID: tile.npcID)),
				isWalkable: tileNPCisOn.isWalkable,
				event: tileNPCisOn.event,
				biome: tileNPCisOn.biome
			), x: position.x, y: position.y)
			return
		}
	}

	private static func hasReachedDestination(_ position: NPCMovingPosition, target: TilePosition) -> Bool {
		target == .init(x: position.x, y: position.y, mapType: position.mapType)
	}

	private static func updateMapForNPCMove(from position: NPCMovingPosition, to newPos: NPCMoving.Position, tile: NPCTile, npcTile: MapTile) async {
		let currentTile = await MapBox.mapType.map.grid[newPos.y][newPos.x] as! MapTile

		let newPosition = NPCMovingPosition(
			x: newPos.x,
			y: newPos.y,
			mapType: position.mapType,
			oldTile: currentTile
		)

		await withTaskGroup { group in
			group.addTask {
				await MapBox.setMapGridTile(
					x: position.x,
					y: position.y,
					tile: position.oldTile,
					mapType: position.mapType
				)
			}
			group.addTask {
				await MapBox.setMapGridTile(
					x: newPos.x,
					y: newPos.y,
					tile: MapTile(
						type: .npc(tile: tile),
						isWalkable: npcTile.isWalkable,
						event: npcTile.event,
						biome: npcTile.biome
					),
					mapType: position.mapType
				)
			}
			group.addTask {
				await Game.shared.updateNPC(oldPosition: position, newPosition: newPosition)
			}
			group.addTask {
				await MapBox.updateTwoTiles(
					x1: newPos.x, y1: newPos.y,
					x2: position.x, y2: position.y
				)
			}
		}
	}

	// static func move(position: NPCMovingPosition) async {
	// 	let tileNPCisOn = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile
	// 	if case let .npc(tile: npcTile) = tileNPCisOn.type, let positionToWalkTo = await npcTile.npc.positionToWalkTo {
	// 		if await isDestinationInCurrentMap(destination: positionToWalkTo, mapType: position.mapType) {
	// 			await moveTo(destination: positionToWalkTo, currentPosition: position, npcTile: npcTile, tileNPCisOn: tileNPCisOn)
	// 		} else {
	// 			await moveToDoor(position: position, npcTile: npcTile, tileNPCisOn: tileNPCisOn)
	// 		}
	// 	}
	// }
	//
	// static func isDestinationInCurrentMap(destination: NPCPosition, mapType: MapType) async -> Bool {
	// 	assert(mapType != .mining, "NPCs should not be moving in the mining map")
	// 	guard destination.mapType == mapType else { return false } // skip awaiting if unnecessary
	//
	// 	let x = await destination.x < mapType.grid[0].count
	// 	let y = await destination.y < mapType.grid.count
	// 	return destination.mapType == mapType && destination.x > 0 && x && destination.y >= 0 && y
	// }
	//
	// static func moveTo(destination: NPCPosition, currentPosition: NPCMovingPosition, npcTile: NPCTile, tileNPCisOn: MapTile) async {
	// 	guard await isDestinationInCurrentMap(destination: destination, mapType: currentPosition.mapType) else { return }
	//
	// 	var currentPosition = currentPosition
	// 	var currentTileNPCisOn = tileNPCisOn
	//
	// 	// while currentPosition.x != destination.x || currentPosition.y != destination.y {
	// 	let nextStep = await nextStepToward(target: destination, current: currentPosition)
	//
	// 	let destinationTile = await MapBox.mapType.map.grid[nextStep.y][nextStep.x] as! MapTile
	//
	// 	guard destinationTile.isWalkable else {
	// 		Logger.warning("NPC can't walk to destination, blocked at \(nextStep)")
	// 		return
	// 	}
	// 	// Restore old tile
	// 	await MapBox.setMapGridTile(
	// 		x: currentPosition.x,
	// 		y: currentPosition.y,
	// 		tile: currentPosition.oldTile,
	// 		mapType: currentPosition.mapType
	// 	)
	//
	// 	// Update new tile to NPC
	// 	await MapBox.setMapGridTile(
	// 		x: nextStep.x,
	// 		y: nextStep.y,
	// 		tile: MapTile(
	// 			type: .npc(tile: npcTile),
	// 			isWalkable: currentTileNPCisOn.isWalkable,
	// 			event: currentTileNPCisOn.event,
	// 			biome: currentTileNPCisOn.biome
	// 		),
	// 		mapType: currentPosition.mapType
	// 	)
	//
	// 	let newCurrentTile = await MapBox.mapType.map.grid[nextStep.y][nextStep.x] as! MapTile
	//
	// 	let newPosition = NPCMovingPosition(
	// 		x: nextStep.x,
	// 		y: nextStep.y,
	// 		mapType: currentPosition.mapType,
	// 		oldTile: newCurrentTile
	// 	)
	//
	// 	await Game.shared.updateNPC(oldPosition: currentPosition, newPosition: newPosition)
	//
	// 	await MapBox.updateTwoTiles(x1: currentPosition.x, y1: currentPosition.y, x2: currentPosition.x, y2: currentPosition.y)
	//
	// 	// let currentMovingTile = NPCMovingPosition(x: currentPosition.x, y: currentPosition.y, mapType: currentPosition.mapType, oldTile: currentTile)
	// 	// let destinationMovingTile = NPCMovingPosition(x: nextStep.x, y: nextStep.y, mapType: destination.mapType, oldTile: destinationTile)
	//
	// 	// Update current info for next step
	// 	currentPosition = NPCMovingPosition(x: nextStep.x, y: nextStep.y, mapType: destination.mapType, oldTile: destinationTile)
	// 	currentTileNPCisOn = destinationTile
	//
	// 	// await Task.sleep(100_000_000) // 100ms between moves (optional for animation)
	// 	Logger.info("NPC is moving to \(nextStep)")
	// 	// }
	// }
	//
	// static func nextStepToward(target toTilePosition: TilePosition, current: NPCMovingPosition) async -> NPCPosition {
	// 	struct Position: Equatable, Hashable {
	// 		var x: Int
	// 		var y: Int
	// 	}
	//
	// 	let targetPosition = Position(x: toTilePosition.x, y: toTilePosition.y)
	// 	let currentPosition = Position(x: current.x, y: current.y)
	// 	let map = await MapBox.mapType.map.grid
	//
	// 	let directions = [(0, 1), (0, -1), (1, 0), (-1, 0)] // Up, Down, Right, Left
	// 	var openSet: [(Position, Int)] = [(currentPosition, 0)] // (Position, cost)
	// 	var cameFrom: [Position: Position] = [:]
	// 	var gScore: [Position: Int] = [currentPosition: 0]
	//
	// 	while !openSet.isEmpty {
	// 		openSet.sort { $0.1 < $1.1 } // Sort by cost
	// 		let (currentNode, _) = openSet.removeFirst()
	//
	// 		if currentNode == targetPosition { // Reached the goal
	// 			var node: Position? = targetPosition
	// 			var path: [Position] = []
	//
	// 			while let n = node, n != currentPosition {
	// 				path.append(n)
	// 				node = cameFrom[n]
	// 			}
	// 			if let next = path.reversed().first {
	// 				return NPCPosition(x: next.x, y: next.y, mapType: current.mapType)
	// 			} else {
	// 				return NPCPosition(x: currentPosition.x, y: currentPosition.y, mapType: current.mapType)
	// 			}
	// 		}
	//
	// 		for (dx, dy) in directions {
	// 			let neighbor = Position(x: currentNode.x + dx, y: currentNode.y + dy)
	//
	// 			if neighbor.x < 0 || neighbor.y < 0 || neighbor.x >= map[0].count || neighbor.y >= map.count {
	// 				continue
	// 			}
	//
	// 			let neighborTile = map[neighbor.y][neighbor.x] as! MapTile
	//
	// 			if case .building = neighborTile.type {
	// 				continue
	// 			}
	//
	// 			let tentativeGScore = gScore[currentNode]! + 1
	// 			if tentativeGScore < (gScore[neighbor] ?? Int.max) {
	// 				cameFrom[neighbor] = currentNode
	// 				gScore[neighbor] = tentativeGScore
	// 				openSet.append((neighbor, tentativeGScore))
	// 			}
	// 		}
	// 	}
	//
	// 	return NPCPosition(x: currentPosition.x, y: currentPosition.y, mapType: current.mapType)
	// }
	//
	// static func moveToDoor(position: NPCMovingPosition, npcTile: NPCTile, tileNPCisOn: MapTile) async {
	// 	// can assume that the door is in the same map as the NPC and destination is not in the same map
	// 	guard let (doorTile, doorPosition) = await findDoorTileForPosition(position) else {
	// 		Logger.error("No door tile found for position \(position)", code: .noDoorTile)
	// 	}
	// 	if case .door = tileNPCisOn.type {
	// 		await switchMaps(from: position, doorTile: doorTile, npcTile: npcTile)
	// 	} else {
	// 		await moveTo(destination: doorPosition, currentPosition: position, npcTile: npcTile, tileNPCisOn: tileNPCisOn)
	// 	}
	// }
	//
	// static func findDoorTileForPosition(_ position: NPCMovingPosition) async -> (doorTile: DoorTile, position: NPCPosition)? {
	// 	let tile = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile
	// 	if case let .door(tile: doorTile) = tile.type {
	// 		return (doorTile, NPCPosition(x: position.x, y: position.y, mapType: position.mapType))
	// 	}
	// 	return nil
	// }
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
