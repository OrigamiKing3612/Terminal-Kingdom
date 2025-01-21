enum MapBuilding {
	static func build(grid: inout [[MapTile]], x: Int, y: Int) {
		if grid[y][x].type != .plain {
			MessageBox.message("You can't build here.", speaker: .game)
			return
		}

		let selectedItem = InventoryBox.buildableItems[InventoryBox.selectedBuildItemIndex]
		if Game.player.has(item: selectedItem.type, count: selectedItem.type == .lumber ? 5 : 1) {
			if Game.stages.builder.stage5Stages == .buildHouse {
				BuildForBuilderStage5.build(grid: &grid, x: x, y: y)
			} else if Game.stages.builder.stage7Stages == .buildInside, case .custom(mapID: _) = MapBox.mapType {
				BuildForBuilderStage7.build(grid: &grid, x: x, y: y)
			} else {
				buildNormally(grid: &grid, x: x, y: y)
			}
		} else {
			MessageBox.message("You don't have enough items to build", speaker: .game)
		}
	}

	static func destory(grid: inout [[MapTile]], x: Int, y: Int) {
		if grid[y][x].type.isBuildable {
			removeNormally(grid: &grid, x: x, y: y)
		} else {
			MessageBox.message("You can't remove this tile.", speaker: .game)
		}
	}

	static func removeNormally(grid: inout [[MapTile]], x: Int, y: Int) {
		let tile = grid[y][x]
		guard tile.type.isBuildable else {
			MessageBox.message("You can't remove this tile.", speaker: .game)
			return
		}
		func placeTile(tile: some BuildableTile, count: Int = 1, name: String, item: () -> ItemType) {
			if tile.isPlacedByPlayer {
				grid[y][x] = MapTile(type: .plain)
				let itemToCollect = item()
				_ = Game.player.collect(item: .init(type: itemToCollect), count: count)
			} else {
				MessageBox.message("You can't remove this \(name).", speaker: .game)
			}
		}
		switch tile.type {
			case let .building(tile: buildingTile):
				placeTile(tile: buildingTile, count: 4, name: "building", item: { .lumber })
			case let .door(tile: doorTile):
				placeTile(tile: doorTile, name: "\(doorTile.type.name) Door") {
					if case let .custom(mapID: id, doorType: doorType) = doorTile.type {
						if let id {
							Game.removeMap(mapID: id)
						}
						return .door(tile: .init(type: .custom(mapID: nil, doorType: doorType)))
					} else {
						return .door(tile: doorTile)
					}
				}
			case let .fence(tile: fenceTile):
				placeTile(tile: fenceTile, name: "fence", item: { .fence })
			case let .gate(tile: gateTile):
				placeTile(tile: gateTile, name: "gate", item: { .gate })
			case .chest:
				// TODO: break chest
				MessageBox.message("You can't remove this chest yet", speaker: .game)
			case let .bed(tile: bedTile):
				placeTile(tile: bedTile, name: "bed", item: { .bed })
			case let .desk(tile: deskTile):
				placeTile(tile: deskTile, name: "desk", item: { .desk })
			default:
				MessageBox.message("This is a not buildable tile", speaker: .game)
		}
	}

	static func buildNormally(grid: inout [[MapTile]], x: Int, y: Int) {
		let selectedItem = InventoryBox.buildableItems[InventoryBox.selectedBuildItemIndex]
		if selectedItem.type == .lumber {
			if Game.player.has(item: .lumber, count: 5) {
				grid[y][x] = MapTile(type: .building(tile: .init(isPlacedByPlayer: true)))
				Game.player.removeItem(item: .lumber, count: 5)
			}
		} else {
			if Game.player.has(item: selectedItem.type, count: 1) {
				if case let .door(tile: tile) = selectedItem.type {
					do {
						let (doorPosition, buildingPerimeter) = try CreateCustomMap.checkDoor(tile: tile, grid: grid, x: x, y: y)
						let map = createCustomMap(buildingPerimeter: buildingPerimeter, doorPosition: doorPosition, doorType: tile.type)
						let customMap = try CustomMap(grid: map)
						if let customMap {
							Game.addMap(map: customMap)
							grid[y][x] = MapTile(type: .door(tile: .init(type: .custom(mapID: customMap.id, doorType: tile.type), isPlacedByPlayer: true)), isWalkable: true, event: .openDoor)
							Game.player.removeItem(item: .door(tile: tile), count: 1)
							if Game.stages.builder.stage5Stages == .buildHouse {
								Game.stages.builder.stage5HasBuiltHouse = true
							}
						}
					} catch {
						MessageBox.message(error.localizedDescription, speaker: .game)
					}
				} else {
					grid[y][x] = MapTile(type: itemTypeToMapTileType(selectedItem.type)!)
					Game.player.removeItem(item: selectedItem.type, count: 1)
				}
			}
		}
	}

	private static func itemTypeToMapTileType(_ itemType: ItemType) -> MapTileType? {
		// only used in building
		switch itemType {
			case .door:
				MessageBox.message("This shouldn't have happen", speaker: .game)
				return nil
			case .fence: return .fence(tile: .init(isPlacedByPlayer: true))
			case .gate: return .gate(tile: .init(isPlacedByPlayer: true))
			case .bed: return .bed(tile: .init(isPlacedByPlayer: true))
			case .desk: return .desk(tile: .init(isPlacedByPlayer: true))
			case .chest: return .chest
			default: return nil
		}
	}

	private static func createCustomMap(buildingPerimeter: BuildingPerimeter, doorPosition: DoorPosition, doorType: DoorTileTypes) -> [[MapTile]] {
		let ratio = 4

		let topLength = buildingPerimeter.top * ratio
		// let bottomLength = buildingPerimeter.bottom * ratio
		let rightLength = buildingPerimeter.rightSide * ratio
		// let leftLength = buildingPerimeter.leftSide * ratio

		var map: [[MapTile]] = Array(repeating: Array(repeating: .init(type: .plain, isWalkable: true), count: topLength), count: rightLength)

		for (indexY, y) in map.enumerated() {
			let buildingTile = MapTile(type: .building(tile: .init(isPlacedByPlayer: false)), isWalkable: false)
			for (indexX, _) in y.enumerated() {
				if indexY == 0 {
					map[indexY][indexX] = buildingTile
				}
				if indexX == 0 {
					map[indexY][indexX] = buildingTile
				}
				if indexY == (rightLength - 1) {
					map[indexY][indexX] = buildingTile
				}
				if indexX == (topLength - 1) {
					map[indexY][indexX] = buildingTile
				}
			}
		}
		// TODO: put door in the position that best matches where it is in the grid
		var doorX, doorY: Int
		switch doorPosition {
			case .top:
				doorX = topLength / 2
				doorY = 0
			case .right:
				doorX = topLength - 1
				doorY = rightLength / 2
			case .left:
				doorX = 0
				doorY = rightLength / 2
			case .bottom:
				doorX = topLength / 2
				doorY = rightLength - 1
		}

		map[doorY][doorX] = .init(type: .door(tile: .init(type: doorType, isPlacedByPlayer: false)), isWalkable: true)

		var startX, startY: Int
		switch doorPosition {
			case .top:
				startX = doorX
				startY = doorY + 1
			case .right:
				startX = doorX - 1
				startY = doorY
			case .left:
				startX = doorX + 1
				startY = doorY
			case .bottom:
				startX = doorX
				startY = doorY - 1
		}
		map[startY][startX] = .init(type: .playerStart, isWalkable: true)

		return map
	}
}

extension Int {
	func isWithInOneOf(_ other: Int) -> Bool {
		self == other || self == other + 1 || self == other - 1
	}
}

private enum BuildForBuilderStage5 {
	static func build(grid: inout [[MapTile]], x: Int, y: Int) {
		var buildingsPlaced: Int { Game.stages.builder.stage5BuildingsPlaced }
		if buildingsPlaced == 0 {
			MapBuilding.buildNormally(grid: &grid, x: x, y: y)
			Game.stages.builder.stage5LastBuildingPlaced = .init(x: x, y: y)
		} else {
			// let lastBuildingPlaced = Game.stages.builder.stage5LastBuildingPlaced
			// if let lastBuildingPlaced {
			// if x.isWithInOneOf(lastBuildingPlaced.x), y.isWithInOneOf(lastBuildingPlaced.y) {
			MapBuilding.buildNormally(grid: &grid, x: x, y: y)
			Game.stages.builder.stage5LastBuildingPlaced = .init(x: x, y: y)
			// } else {
			// 	MessageBox.message("To build a house, you should only build next to the last building you placed.", speaker: .game)
			// 	return
			// }
			// } else {
			// 	MessageBox.message("You haven't placed a building?", speaker: .game)
			// 	return
			// }
		}
	}
}

private enum BuildForBuilderStage7 {
	static func build(grid: inout [[MapTile]], x: Int, y: Int) {
		// This will only be called inside of a house.
		MapBuilding.buildNormally(grid: &grid, x: x, y: y)
		Game.stages.builder.stage7HasBuiltInside = true
	}
}
