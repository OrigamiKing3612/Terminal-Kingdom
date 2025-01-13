enum MapBox {
	nonisolated(unsafe) static var mainMap: MainMap = .init()
	nonisolated(unsafe) static var miningMap: MineMap = .init()
	nonisolated(unsafe) static var buildingMap: BuildingMap = .init(.castle(side: .left))
	nonisolated(unsafe) static var showMapBox = true {
		didSet {
			if showMapBox {
				mapBox()
			} else {
				clear()
			}
		}
	}

	nonisolated(unsafe) static var mapType: MapType {
		get {
			Game.player.mapType
		}
		set {
			Game.player.setMapType(newValue)
			// }
			// didSet {
			// 	Game.mapType = mapType
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

		sides()

		switch mapType {
			case .mainMap:
				mainMap.map()
			case .mining:
				miningMap.map()
			default:
				buildingMap.map()
		}
	}

	static func sides() {
		Screen.print(x: q1StartX, y: q1StartY, String(repeating: "=", count: q1Width + 4).styled(with: [.bold, .blue], styledIf: Game.isBuilding))
		for y in (q1StartY + 1) ..< q1EndY {
			Screen.print(x: q1StartX, y: y, "|".styled(with: [.bold, .blue], styledIf: Game.isBuilding))
			Screen.print(x: q1EndX - 1, y: y, "|".styled(with: [.bold, .blue], styledIf: Game.isBuilding))
		}
		Screen.print(x: q1StartX, y: q1EndY, String(repeating: "=", count: q1Width + 4).styled(with: [.bold, .blue], styledIf: Game.isBuilding))
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

	static func build() {
		if mapType == .mainMap {
			mainMap.build()
		}
	}

	static func updateTile(newTile: MapTile) {
		switch mapType {
			case .mainMap:
				mainMap.updateTile(newTile: newTile)
			case .mining:
				break
			default:
				buildingMap.updateTile(newTile: newTile)
		}
	}
}

enum MapType: Codable, Equatable {
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
