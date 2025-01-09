enum MapBox {
	nonisolated(unsafe) static var mainMap: MainMap = .init()
	nonisolated(unsafe) static var miningMap: MineMap = .init()
	nonisolated(unsafe) static var buildingMap: BuildingMap = .init(.blacksmith)
	nonisolated(unsafe) static var showMapBox = true {
		didSet {
			if showMapBox {
				mapBox()
			} else {
				clear()
			}
		}
	}

	nonisolated(unsafe) static var mapType: MapType = .mainMap {
		didSet {
			switch mapType {
				case .mainMap:
					break
				case .mining:
					miningMap = .init()
				default:
					buildingMap = .init(mapType)
			}
			mapBox()
		}
	}

	static var player: Player {
		mapType.map.player
	}

	static var tilePlayerIsOn: MapTile {
		mapType.map.tilePlayerIsOn as! MapTile
	}

	static func mapBox() {
		clear()

		Screen.print(x: q1StartX, y: q1StartY, String(repeating: "=", count: q1Width + 3))
		for y in (q1StartY + 1) ..< q1EndY {
			Screen.print(x: q1StartX, y: y, "|")
			Screen.print(x: q1EndX - 1, y: y, "|")
		}
		Screen.print(x: q1StartX, y: q1EndY, String(repeating: "=", count: q1Width + 3))

		switch mapType {
			case .mainMap:
				mainMap.map()
			case .mining:
				miningMap.map()
			default:
				buildingMap.map()
		}
	}

	static func clear() {
		let spaceString = String(repeating: " ", count: q1Width + 1)
		for y in (q1StartY + 1) ..< q1EndY {
			Screen.print(x: q1StartX + 1, y: y, spaceString)
		}
	}

	static func movePlayer(_ direction: Direction) {
		switch mapType {
			case .mainMap:
				mainMap.movePlayer(direction)
			case .mining:
				miningMap.movePlayer(direction)
			default:
				buildingMap.movePlayer(direction)
		}
	}

	static func interactWithTile() {
		mapType.map.interactWithTile()
	}

	static func findTile(type: MapTileType, in grid: [[MapTile]]) -> (x: Int, y: Int)? {
		for (y, row) in grid.enumerated() {
			if let x = row.firstIndex(where: { tile in
				if case let .door(doorTile) = tile.type, case let .door(checkTile) = type {
					return doorTile == checkTile
				}
				return tile.type == type
			}) {
				return (x, y)
			}
		}
		return nil
	}
}

enum MapType: Equatable {
	case mainMap
	case mining
	case castle(side: CastleSide)
	case blacksmith
	case mine
	case shop
	case builder
	case hunting_area
	case inventor
	case house
	case stable
	case farm(type: FarmDoors)
	case hospital(side: HospitalSide)
	case carpenter
	case restaurant
	case potter

	var map: any MapBoxMap {
		switch self {
			case .mainMap:
				MapBox.mainMap
			case .mining:
				MapBox.miningMap
			default:
				MapBox.buildingMap
		}
	}
}

enum Direction {
	case up, down, left, right
}

struct Player: Codable {
	var x: Int
	var y: Int
}

protocol MapBoxMap {
	associatedtype pTile: Tile
	var grid: [[pTile]] { get set }
	var width: Int { get set }
	var height: Int { get set }

	var player: Player { get }
	var tilePlayerIsOn: pTile { get }
	func isWalkable(x: Int, y: Int) -> Bool
	func render(playerX: Int, playerY: Int, viewportWidth: Int, viewportHeight: Int)
	func interactWithTile()

	mutating func updateDimensions(width: Int, height: Int)
	mutating func movePlayer(_ direction: Direction)
	mutating func map()
}
