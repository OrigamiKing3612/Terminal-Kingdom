enum CreateCustomMap {
	static func checkDoor(tile: DoorTile, grid: [[MapTile]], x: Int, y: Int) throws(DoorPlaceError) -> BuildingPerimeter {
		if !(grid[y][x].type == .plain) {
			throw .noSpace
		}
		if !Game.player.has(item: .door(tile: tile), count: 1) {
			throw DoorPlaceError.noDoor
		}
		let doorPosition = try checkBuildingsNearby(grid: grid, x: x, y: y)

		return switch doorPosition {
			case .bottom: CreateMap.bottom()
			case .left: CreateMap.leftSide()
			case .right: CreateMap.rightSide()
			case .top: CreateMap.top()
		}
	}

	private static func checkBuildingsNearby(grid: [[MapTile]], x: Int, y: Int) throws(DoorPlaceError) -> DoorPosition {
		let nearbyTiles = [
			grid[y - 1][x],
			grid[y + 1][x],
			grid[y][x - 1],
			grid[y][x + 1],
		]
		var buildingsNearby = 0
		for tile in nearbyTiles {
			if tile.type == .building(tile: .init(isPlacedByPlayer: true)) {
				buildingsNearby += 1
			}
		}

		if buildingsNearby < 3 {
			throw DoorPlaceError.notEnoughBuildingsNearby
		}

		if grid[y - 1][x].type == .building(tile: .init(isPlacedByPlayer: true)), grid[y + 1][x].type == .building(tile: .init(isPlacedByPlayer: true)) {
			if grid[y][x - 1].type == .building(tile: .init(isPlacedByPlayer: true)) {
				return .right
			}
			if grid[y][x + 1].type == .building(tile: .init(isPlacedByPlayer: true)) {
				return .left
			}
		} else if grid[y][x - 1].type == .building(tile: .init(isPlacedByPlayer: true)), grid[y][x + 1].type == .building(tile: .init(isPlacedByPlayer: true)) {
			if grid[y - 1][x].type == .building(tile: .init(isPlacedByPlayer: true)) {
				return .top
			}
			if grid[y + 1][x].type == .building(tile: .init(isPlacedByPlayer: true)) {
				return .bottom
			}
		}
	}

	private enum CreateMap {
		private enum CheckDoorDirection {
			case up, down, left, right
		}

		static func rightSide() -> BuildingPerimeter {
//
		}

		static func leftSide() -> BuildingPerimeter {
//
		}

		static func top() -> BuildingPerimeter {
//
		}

		static func bottom() -> BuildingPerimeter {
			//       var hasReachedDoor = false
			// var direction: CheckDoorDirection = .down
			//
			// while hasReachedDoor == false {
			// 	switch direction {
			// 		case .down:
			// 			if grid[y][x + 1].type == .building(tile: .init(isPlacedByPlayer: true)) {
			// 				buildingPerimeter.rightSide += 1
			// 			}
			// 	}
			// }
		}
	}
}

struct BuildingPerimeter {
	let rightSide: Int
	let leftSide: Int
	let top: Int
	let bottom: Int

	init() {
		rightSide = 0
		leftSide = 0
		top = 0
		bottom = 0
	}
}

enum DoorPosition {
	case top, bottom, right, left
}
