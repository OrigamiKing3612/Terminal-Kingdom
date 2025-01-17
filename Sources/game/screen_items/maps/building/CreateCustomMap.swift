import Foundation

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

		var createMap = CreateMap(grid: grid, x: x, y: y, doorPosition: doorPosition)
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
		var buildingsNearby = 0
		var validDoorPosition: DoorPosition?

		var buildingOnTheTop = false
		var buildingOnTheBottom = false
		var buildingOnTheLeft = false
		var buildingOnTheRight = false

		if isBuilding(grid[y + 1][x]) {
			buildingOnTheTop = true
			buildingsNearby += 1
		}

		if isBuilding(grid[y - 1][x]) {
			buildingOnTheBottom = true
			buildingsNearby += 1
		}

		if isBuilding(grid[y][x + 1]) {
			buildingOnTheRight = true
			buildingsNearby += 1
		}

		if isBuilding(grid[y][x - 1]) {
			buildingOnTheLeft = true
			buildingsNearby += 1
		}

		if buildingOnTheTop == false {
			validDoorPosition = .bottom
		}

		if buildingOnTheBottom == false {
			validDoorPosition = .top
		}

		if buildingOnTheLeft == false {
			validDoorPosition = .right
		}

		if buildingOnTheRight == false {
			validDoorPosition = .left
		}

		guard buildingsNearby == 3, let doorPosition = validDoorPosition else {
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
		let startX: Int
		let startY: Int
		let doorPosition: DoorPosition

		init(grid: [[MapTile]], x: Int, y: Int, doorPosition: DoorPosition) {
			self.grid = grid
			self.x = x
			self.y = y
			startX = x
			startY = y
			self.doorPosition = doorPosition
		}

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
			var hasReachedStart = false
			var direction = startingDirection
			var buildingPerimeter = BuildingPerimeter()

			struct Position: Hashable {
				var x: Int
				var y: Int
			}

			var visited: Set<Position> = []
			let startingPosition = Position(x: x, y: y)
			visited.insert(startingPosition)

			while !hasReachedStart {
				// TODO: if moving the coordinates to 0,0 this might now work
				switch direction {
					case .right:
						x += 1
						if isWhereDoorWillGo(at: x, y: y) {
							hasReachedStart = (x == startX && y == startY)
							buildingPerimeter.rightSide += 1
						} else if isBuilding(at: x, y: y) {
							buildingPerimeter.rightSide += 1
						} else {
							direction = .up
							x -= 1 // Backtrack to original position
						}
					case .up:
						y -= 1
						if isWhereDoorWillGo(at: x, y: y) {
							hasReachedStart = (x == startX && y == startY)
							buildingPerimeter.top += 1
						} else if isBuilding(at: x, y: y) {
							buildingPerimeter.top += 1
						} else {
							direction = .left
							y += 1 // Backtrack to original position
						}
					case .left:
						x -= 1
						if isWhereDoorWillGo(at: x, y: y) {
							hasReachedStart = (x == startX && y == startY)
							buildingPerimeter.leftSide += 1
						} else if isBuilding(at: x, y: y) {
							buildingPerimeter.leftSide += 1
						} else {
							direction = .down
							x += 1 // Backtrack to original position
						}
					case .down:
						y += 1
						if isWhereDoorWillGo(at: x, y: y) {
							hasReachedStart = (x == startX && y == startY)
							buildingPerimeter.bottom += 1
						} else if isBuilding(at: x, y: y) {
							buildingPerimeter.bottom += 1
						} else {
							direction = .right
							y -= 1 // Backtrack to original position
						}
				}

				// this = the door position

				let currentPosition = Position(x: x, y: y)
				visited.insert(currentPosition)

				if currentPosition == startingPosition, visited.count > 1 {
					hasReachedStart = true
				}
			}
			var newBuildingPerimeter: BuildingPerimeter = .init()
			switch doorPosition {
				case .right:
					break
				case .top:
					newBuildingPerimeter.top = buildingPerimeter.top + 1 + buildingPerimeter.bottom
					newBuildingPerimeter.bottom = buildingPerimeter.top + 1 + buildingPerimeter.bottom
					newBuildingPerimeter.rightSide = buildingPerimeter.rightSide - 1
					newBuildingPerimeter.leftSide = buildingPerimeter.leftSide - 1
				case .left:
					break
				case .bottom:
					break
			}

			return newBuildingPerimeter
		}

		private func isBuilding(at x: Int, y: Int) -> Bool {
			guard grid.indices.contains(y), grid[y].indices.contains(x) else { return false }
			if case let .building(tile: building) = grid[y][x].type {
				return building.isPlacedByPlayer
			}
			return false
		}

		private func isWhereDoorWillGo(at x: Int, y: Int) -> Bool {
			x == startX && y == startY
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
