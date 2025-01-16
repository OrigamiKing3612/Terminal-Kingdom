enum MapBuilding {
	static func build(grid: inout [[MapTile]], x: Int, y: Int) {
		if grid[y][x].type != .plain {
			MessageBox.message("You can't build here.", speaker: .game)
			return
		}
		if Game.player.has(item: .lumber, count: 5) {
			if Game.stages.builder.stage5Stages == .buildHouse {
				BuildForBuilderStage5.build(grid: &grid, x: x, y: y)
			} else if Game.stages.builder.stage7Stages == .buildInside, MapBox.mapType == .house {
				BuildForBuilderStage7.build(grid: &grid, x: x, y: y)
			} else {
				buildNormally(grid: &grid, x: x, y: y)
			}
		} else {
			MessageBox.message("You need 5 lumber to build a building.", speaker: .game)
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
		if case let .building(tile: buildingTile) = tile.type {
			if buildingTile.isPlacedByPlayer {
				grid[y][x] = MapTile(type: .plain)
				_ = Game.player.collect(item: .init(type: .lumber), count: 4)
			} else {
				MessageBox.message("You can't remove this building.", speaker: .game)
			}
		} else if case let .door(tile: doorTile) = tile.type {
			if doorTile.isPlacedByPlayer {
				grid[y][x] = MapTile(type: .plain)
				_ = Game.player.collect(item: .init(type: .door(tile: doorTile)), count: 1)
			} else {
				MessageBox.message("You can't remove this door.", speaker: .game)
			}
		} else {
			// if doorTile.isPlacedByPlayer {
			// 	grid[player.y][player.x] = MapTile(type: .plain)
			// 	_ = Game.player.collect(item: .init(type: .door(tile: doorTile)), count: 1)
			// } else {
			// 	MessageBox.message("You can't remove this door.", speaker: .game)
			// }
			MessageBox.message("You can't remove this tile.", speaker: .game)
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
						let buildingPerimeter = try CreateCustomMap.checkDoor(tile: tile, grid: grid, x: x, y: y)
						let map = getDoorMap(buildingPerimeter: buildingPerimeter, grid: grid, x: x, y: y)
						grid[y][x] = MapTile(type: .door(tile: .init(tileType: tile.tileType, isPlacedByPlayer: true, map: map)), isWalkable: true, event: .openDoor(tile: .init(tileType: tile.tileType)))
						Game.player.removeItem(item: .door(tile: tile), count: 1)
						if Game.stages.builder.stage5Stages == .buildHouse {
							Game.stages.builder.stage5HasBuiltHouse = true
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
		switch itemType {
			case .door:
				MessageBox.message("This shouldn't have happen", speaker: .game)
				return nil
			case .fence: return .fence
			case .gate: return .gate
			default: return nil
		}
	}

	private static func getDoorMap(buildingPerimeter _: BuildingPerimeter, grid _: [[MapTile]], x _: Int, y _: Int) -> [[MapTile]] {
		var map: [[MapTile]]

		// if grid[y - 1][x].type == .building(tile: .init(isPlacedByPlayer: true)) {
		// 	map = [
		// 		[grid[y - 1][x], grid[y - 1][x + 1]],
		// 		[grid[y][x], grid[y][x + 1]],
		// 	]
		// } else if grid[y + 1][x].type == .building(tile: .init(isPlacedByPlayer: true)) {
		// 	map = [
		// 		[grid[y][x], grid[y][x + 1]],
		// 		[grid[y + 1][x], grid[y + 1][x + 1]],
		// 	]
		// } else if grid[y][x - 1].type == .building(tile: .init(isPlacedByPlayer: true)) {
		// 	map = [
		// 		[grid[y][x - 1], grid[y][x]],
		// 		[grid[y + 1][x - 1], grid[y + 1][x]],
		// 	]
		// } else {
		// 	map = [
		// 		[grid[y][x], grid[y][x + 1]],
		// 		[grid[y + 1][x], grid[y + 1][x + 1]],
		// 	]
		// }

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
			let lastBuildingPlaced = Game.stages.builder.stage5LastBuildingPlaced
			if let lastBuildingPlaced {
				// if x.isWithInOneOf(lastBuildingPlaced.x), y.isWithInOneOf(lastBuildingPlaced.y) {
				MapBuilding.buildNormally(grid: &grid, x: x, y: y)
				Game.stages.builder.stage5LastBuildingPlaced = .init(x: x, y: y)
				// } else {
				// 	MessageBox.message("To build a house, you should only build next to the last building you placed.", speaker: .game)
				// 	return
				// }
			} else {
				MessageBox.message("You haven't placed a building?", speaker: .game)
				return
			}
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
