extension NPCTile {
	static func switchMaps(from currentPosition: NPCMovingPosition, doorTile: DoorTile, npcTile: NPCTile) async {
		if currentPosition.mapType == .mainMap {
			await placeNPCInCustomMap(doorTile: doorTile, currentPosition: currentPosition, npcTile: npcTile, tileNPCisOn: currentPosition.oldTile)
		} else {
			await placeNPCInMainMap(doorTile: doorTile, currentPosition: currentPosition, npcTile: npcTile, tileNPCisOn: currentPosition.oldTile)
		}
	}

	private static func placeNPCInCustomMap(doorTile: DoorTile, currentPosition: NPCMovingPosition, npcTile: NPCTile, tileNPCisOn: MapTile) async {
		guard case let .custom(mapID, _) = doorTile.type else { return }
		guard let mapID else { return }
		guard let grid = await Game.shared.maps.customMaps[mapID]?.grid else { return }

		for (yIndex, y) in grid.enumerated() {
			if let xIndex = y.firstIndex(where: { if case .door = $0.type { true } else { false }}) {
				// Restore the door tile in MainMap
				await MapBox.updateTile(newTile: MapTile(
					type: .door(tile: doorTile),
					isWalkable: tileNPCisOn.isWalkable,
					event: tileNPCisOn.event,
					biome: tileNPCisOn.biome
				), x: currentPosition.x, y: currentPosition.y)
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
				await Game.shared.npcs.removeNPCPosition(npcID: npcTile.npcID)
				newGrid[npcY][npcX] = MapTile(
					type: .npc(tile: .init(id: npcTile.id, npcID: npcTile.npcID)),
					isWalkable: tileNPCisOn.isWalkable,
					event: tileNPCisOn.event,
					biome: tileNPCisOn.biome
				)
				await Game.shared.maps.updateCustomMap(id: mapID, with: newGrid)
				break
			}
		}
		// await Game.shared.npcs.updateNPCMapType(npcID: npcTile.npcID, newMapType: .custom(mapID: mapID))
	}

	private static func placeNPCInMainMap(doorTile: DoorTile, currentPosition: NPCMovingPosition, npcTile: NPCTile, tileNPCisOn: MapTile) async {
		guard case let .custom(mapID) = currentPosition.mapType else { return }
		let mainGrid = await MapBox.mapType.map.grid as! [[MapTile]]

		if var customGrid = await Game.shared.maps.customMaps[mapID]?.grid {
			customGrid[currentPosition.y][currentPosition.x] = MapTile(
				type: .door(tile: doorTile),
				isWalkable: tileNPCisOn.isWalkable,
				event: tileNPCisOn.event,
				biome: tileNPCisOn.biome
			)
			await Game.shared.maps.updateCustomMap(id: mapID, with: customGrid)
		}

		// Find the door tile in the main map
		for (yIndex, row) in mainGrid.enumerated() {
			//! TODO: FIX THIS, this is not the correct way to find the door tile, this is any door tile that is the type
			// not the same door tile.
			if let xIndex = row.firstIndex(where: { if case .door = $0.type { true } else { false }}) {
				var doorPosition: DoorPosition = .bottom
				if yIndex == 0 {
					doorPosition = .top
				} else if yIndex == mainGrid.count - 1 {
					doorPosition = .bottom
				} else if xIndex == 0 {
					doorPosition = .left
				} else if xIndex == row.count - 1 {
					doorPosition = .right
				}
				let npcX: Int
				let npcY: Int
				switch doorPosition {
					case .left:
						npcX = xIndex + 1
						npcY = yIndex
					case .right:
						npcX = xIndex - 1
						npcY = yIndex
					case .top:
						npcX = xIndex
						npcY = yIndex + 1
					case .bottom:
						npcX = xIndex
						npcY = yIndex - 1
				}

				await Game.shared.npcs.removeNPCPosition(npcID: npcTile.npcID)
				await MapBox.updateTile(newTile: MapTile(
					type: .npc(tile: .init(id: npcTile.id, npcID: npcTile.npcID)),
					isWalkable: tileNPCisOn.isWalkable,
					event: tileNPCisOn.event,
					biome: tileNPCisOn.biome
				), x: npcX, y: npcY)
				break
			}
		}
		// await Game.shared.npcs.updateNPCMapType(npcID: npcTile.npcID, newMapType: .mainMap)
	}
}
