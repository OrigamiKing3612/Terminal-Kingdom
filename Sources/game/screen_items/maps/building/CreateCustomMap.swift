import Foundation

enum CreateCustomMap {
	static func checkDoor(tile: DoorTile, grid: [[MapTile]], x: Int, y: Int) async throws(DoorPlaceError) -> (DoorPosition, BuildingPerimeter) {
		guard y > 0, y < grid.count - 1, x > 0, x < grid[0].count - 1 else {
			throw .invalidPosition
		}
		if !(grid[y][x].type == .plain) {
			throw .noSpace
		}
		if await !Game.shared.player.has(item: .door(tile: tile), count: 1) {
			throw .noDoor
		}
		let doorPosition = try getDoorPosition(grid: grid, x: x, y: y)
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

	private static func getDoorPosition(grid: [[MapTile]], x: Int, y: Int) throws(DoorPlaceError) -> DoorPosition {
		var buildingsNearby = 0
		var validDoorPosition: DoorPosition?

		var buildingOnTheTop = false
		var buildingOnTheBottom = false
		var buildingOnTheLeft = false
		var buildingOnTheRight = false

		if isBuilding(grid, x: x, y: y + 1) {
			buildingOnTheTop = true
			buildingsNearby += 1
		}

		if isBuilding(grid, x: x, y: y - 1) {
			buildingOnTheBottom = true
			buildingsNearby += 1
		}

		if isBuilding(grid, x: x + 1, y: y) {
			buildingOnTheRight = true
			buildingsNearby += 1
		}

		if isBuilding(grid, x: x - 1, y: y) {
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
			validDoorPosition = .left
		}

		if buildingOnTheRight == false {
			validDoorPosition = .right
		}

		guard let doorPosition = validDoorPosition else {
			throw .invalidPosition
		}

		guard buildingsNearby == 3 else {
			throw .notEnoughBuildingsNearby
		}
		return doorPosition
	}

	private static func isBuilding(_ grid: [[MapTile]], x: Int, y: Int) -> Bool {
		guard grid.indices.contains(y), grid[y].indices.contains(x) else { return false }
		if case let .building(tile: building) = grid[y][x].type {
			return building.isPlacedByPlayer
		}
		return false
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
