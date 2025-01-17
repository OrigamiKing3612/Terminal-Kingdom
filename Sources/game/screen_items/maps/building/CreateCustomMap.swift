enum CreateCustomMap {
	static func checkDoor(tile: DoorTile, grid: [[MapTile]], x: Int, y: Int) throws(DoorPlaceError) -> (DoorPosition, BuildingPerimeter) {
		guard y > 0, y < grid.count - 1, x > 0, x < grid[0].count - 1 else {
			throw .invalidPosition
		}
		if !(grid[y][x].type == .plain) {
			throw .noSpace
		}
		if !Game.player.has(item: .door(tile: tile), count: 1) {
			throw .noDoor
		}

		let doorPosition = try checkBuildingsNearby(grid: grid, x: x, y: y)

		var createMap = CreateMap(grid: grid, x: x, y: y)
		let perimeter = switch doorPosition {
			case .bottom: createMap.bottom()
			case .left: createMap.leftSide()
			case .right: createMap.rightSide()
			case .top: createMap.top()
		}
		if (perimeter.top != perimeter.bottom) || (perimeter.leftSide != perimeter.rightSide) {
			throw .notARectangle
		}
		return (doorPosition, perimeter)
	}

	private static func checkBuildingsNearby(grid: [[MapTile]], x: Int, y: Int) throws(DoorPlaceError) -> DoorPosition {
		let nearbyTiles = [
			(x, y - 1, DoorPosition.top),
			(x, y + 1, DoorPosition.bottom),
			(x - 1, y, DoorPosition.left),
			(x + 1, y, DoorPosition.right),
		]

		var buildingsNearby = 0
		var validDoorPosition: DoorPosition?

		for (nx, ny, position) in nearbyTiles {
			if grid.indices.contains(ny), grid[ny].indices.contains(nx), isBuilding(grid[ny][nx]) {
				buildingsNearby += 1
				validDoorPosition = position
			}
		}

		guard buildingsNearby >= 3, let doorPosition = validDoorPosition else {
			throw DoorPlaceError.notEnoughBuildingsNearby
		}

		return doorPosition
	}

	private static func isBuilding(_ tile: MapTile) -> Bool {
		if case let .building(tile: building) = tile.type, building.isPlacedByPlayer {
			return true
		}
		return false
	}

	private struct CreateMap {
		var grid: [[MapTile]]
		var x: Int
		var y: Int

		private enum CheckDoorDirection {
			case up, down, left, right
		}

		mutating func rightSide() -> BuildingPerimeter {
			calculatePerimeter(startingDirection: .up)
		}

		mutating func leftSide() -> BuildingPerimeter {
			calculatePerimeter(startingDirection: .down)
		}

		mutating func top() -> BuildingPerimeter {
			calculatePerimeter(startingDirection: .left)
		}

		mutating func bottom() -> BuildingPerimeter {
			calculatePerimeter(startingDirection: .right)
		}

		private mutating func calculatePerimeter(startingDirection: CheckDoorDirection) -> BuildingPerimeter {
			var hasReachedDoor = false
			var direction = startingDirection
			var buildingPerimeter = BuildingPerimeter()

			while !hasReachedDoor {
				switch direction {
					case .right:
						x += 1
						if isBuilding(at: x, y: y) {
							buildingPerimeter.rightSide += 1
						} else if isDoor(at: x + 1, y: y) {
							hasReachedDoor = true
						} else {
							direction = .up
						}
					case .up:
						y -= 1
						if isBuilding(at: x, y: y) {
							buildingPerimeter.top += 1
						} else if isDoor(at: x, y: y - 1) {
							hasReachedDoor = true
						} else {
							direction = .left
						}
					case .left:
						x -= 1
						if isBuilding(at: x, y: y) {
							buildingPerimeter.leftSide += 1
						} else if isDoor(at: x - 1, y: y) {
							hasReachedDoor = true
						} else {
							direction = .down
						}
					case .down:
						y += 1
						if isBuilding(at: x, y: y) {
							buildingPerimeter.bottom += 1
						} else if isDoor(at: x, y: y + 1) {
							hasReachedDoor = true
						} else {
							direction = .right
						}
				}
			}

			return buildingPerimeter
		}

		private func isBuilding(at x: Int, y: Int) -> Bool {
			guard grid.indices.contains(y), grid[y].indices.contains(x) else { return false }
			if case let .building(tile: building) = grid[y][x].type {
				return building.isPlacedByPlayer
			}
			return false
		}

		private func isDoor(at x: Int, y: Int) -> Bool {
			guard grid.indices.contains(y), grid[y].indices.contains(x) else { return false }
			if case let .door(tile: door) = grid[y][x].type {
				return door.isPlacedByPlayer
			}
			return false
		}
	}
}

struct BuildingPerimeter {
	var rightSide: Int = 0
	var leftSide: Int = 0
	var top: Int = 0
	var bottom: Int = 0
}

enum DoorPosition {
	case top, bottom, right, left
}
