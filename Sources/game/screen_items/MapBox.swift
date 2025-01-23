import Foundation

//! TODO: could this be better?
actor MapBoxActor {
	nonisolated(unsafe) static var shared = MapBoxActor()
	var mainMap: MainMap?
	private(set) var miningMap: MineMap?
	private(set) var buildingMap: BuildingMap?
	private(set) var showMapBox = true {
		//! TODO: figure out something better
		// private(set) and a set func that does this?
		didSet {
			if showMapBox {
				Task {
					await MapBox.mapBox()
				}
			} else {
				MapBox.clear()
			}
		}
	}

	private init() {
		self.mainMap = nil
		self.miningMap = nil
		self.buildingMap = nil
	}

	init() async {
		self.mainMap = await MainMap()
		self.miningMap = await MineMap()
		self.buildingMap = await BuildingMap(.castle(side: .left))
	}

	func updateMainMapTile(at x: Int, y: Int, with tile: MapTile) async {
		mainMap!.grid[y][x] = tile
	}

	func updateMiningMapTile(at x: Int, y: Int, with tile: MineTile) async {
		miningMap!.grid[y][x] = tile
	}

	func updateBuildingMapTile(at x: Int, y: Int, with tile: MapTile) async {
		buildingMap!.grid[y][x] = tile
	}

	func updateMainMapTile(newTile: MapTile) async {
		mainMap!.updateTile(newTile: newTile)
	}

	func updateBuildingMapTile(newTile: MapTile) async {
		buildingMap!.updateTile(newTile: newTile)
	}

	func resetMiningMap() async {
		miningMap = await .init()
	}

	func resetBuildingMap(_ mapType: MapType) async {
		buildingMap = await .init(mapType)
	}

	func mainMapBuild() async {
		var map = mainMap
		await map!.build()
		mainMap = map
	}

	func mainMapDestroy() async {
		var map = mainMap
		await map!.destroy()
		mainMap = map
	}

	func buildingMapBuild() async {
		var map = buildingMap
		await map!.build()
		buildingMap = map
	}

	func buildingMapDestroy() async {
		var map = buildingMap
		await map!.destroy()
		buildingMap = map
	}

	func mainMapMovePlayer(_ direction: PlayerDirection) async {
		var map = mainMap
		await map!.movePlayer(direction)
		mainMap = map
	}

	func mineMapMovePlayer(_ direction: PlayerDirection) async {
		var map = miningMap
		await map!.movePlayer(direction)
		miningMap = map
	}

	func buildingMapMovePlayer(_ direction: PlayerDirection) async {
		var map = buildingMap
		await map!.movePlayer(direction)
		buildingMap = map
	}

	func mainMap() async {
		var map = mainMap
		await map!.map()
		mainMap = map
	}

	func buildingMap() async {
		var map = buildingMap
		await map!.map()
		buildingMap = map
	}

	func miningMap() async {
		var map = miningMap
		await map!.map()
		miningMap = map
	}

	func showMapBox() async {
		showMapBox = true
	}

	func hideMapBox() async {
		showMapBox = false
	}

	func setBuildingMapPlayer(x: Int, y: Int) async {
		var map = buildingMap
		await map!.setPlayer(x: x, y: y)
		buildingMap = map
	}

	func setMainMapPlayerPosition(_ position: (x: Int, y: Int)) async {
		var map = mainMap
		await map!.setPlayerPosition(position)
		mainMap = map
	}
}

enum MapBox {
	static var mainMap: MainMap {
		get async { await MapBoxActor.shared.mainMap! }
	}

	static var miningMap: MineMap {
		get async { await MapBoxActor.shared.miningMap! }
	}

	static var buildingMap: BuildingMap {
		get async { await MapBoxActor.shared.buildingMap! }
	}

	static var showMapBox: Bool {
		get async { await MapBoxActor.shared.showMapBox }
	}

	static var mapType: MapType {
		get async { await Game.shared.player.mapType }
	}

	static var player: Player {
		get async { await mapType.map.player }
	}

	static var tilePlayerIsOn: MapTile {
		get async { await mapType.map.tilePlayerIsOn as! MapTile }
	}

	static func mapBox() async {
		clear()
		await sides()

		switch await mapType {
			case .mainMap:
				await MapBoxActor.shared.mainMap()
			case .mining:
				await MapBoxActor.shared.miningMap()
			default:
				await MapBoxActor.shared.buildingMap()
		}
	}

	static func sides() async {
		await Screen.print(x: startX, y: startY - 1, String(repeating: Game.shared.horizontalLine, count: width + 1).styled(with: [.bold, .blue], styledIf: Game.shared.isBuilding))
		for y in startY ..< (endY + 1) {
			await Screen.print(x: startX - 1, y: y, Game.shared.verticalLine.styled(with: [.bold, .blue], styledIf: Game.shared.isBuilding))
			await Screen.print(x: endX, y: y, Game.shared.verticalLine.styled(with: [.bold, .blue], styledIf: Game.shared.isBuilding))
		}
		await Screen.print(x: startX, y: endY, String(repeating: Game.shared.horizontalLine, count: width).styled(with: [.bold, .blue], styledIf: Game.shared.isBuilding))
	}

	static func clear() {
		let spaceString = String(repeating: " ", count: width)
		for y in startY ..< endY {
			Screen.print(x: startX, y: y, spaceString)
		}
	}

	static func movePlayer(_ direction: PlayerDirection) async {
		switch await mapType {
			case .mainMap:
				await MapBoxActor.shared.mainMapMovePlayer(direction)
			case .mining:
				await MapBoxActor.shared.mineMapMovePlayer(direction)
			default:
				await MapBoxActor.shared.buildingMapMovePlayer(direction)
		}
	}

	static func interactWithTile() async {
		await mapType.map.interactWithTile()
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

	static func destroy() async {
		switch await mapType {
			case .mainMap:
				await MapBoxActor.shared.mainMapDestroy()
			case .mining:
				break
			default:
				await MapBoxActor.shared.buildingMapDestroy()
		}
	}

	static func build() async {
		switch await mapType {
			case .mainMap:
				await MapBoxActor.shared.mainMapBuild()
			case .mining:
				break
			default:
				await MapBoxActor.shared.buildingMapBuild()
		}
	}

	static func updateTile(newTile: MapTile) async {
		switch await mapType {
			case .mainMap:
				await MapBoxActor.shared.updateMainMapTile(newTile: newTile)
			case .mining:
				break
			default:
				await MapBoxActor.shared.updateBuildingMapTile(newTile: newTile)
		}
	}

	static func setMapType(_ mapType: MapType) async {
		await Game.shared.player.setMapType(mapType)
		switch mapType {
			case .mainMap:
				break
			case .mining:
				await MapBoxActor.shared.resetMiningMap()
			default:
				await MapBoxActor.shared.resetBuildingMap(mapType)
		}
		await mapBox()
	}

	static func showMapBox() async {
		await MapBoxActor.shared.showMapBox()
	}

	static func hideMapBox() async {
		await MapBoxActor.shared.hideMapBox()
	}

	static func setMainMapGridTile(x: Int, y: Int, tile: MapTile) async {
		await MapBoxActor.shared.updateMainMapTile(at: x, y: y, with: tile)
	}

	static func setMainMapGridTile(tile: MapTile) async {
		await MapBoxActor.shared.updateMainMapTile(at: MapBox.player.x, y: MapBox.player.y, with: tile)
	}

	static func resetMiningMap() async {
		await MapBoxActor.shared.resetMiningMap()
	}

	static func resetBuildingMap(_ mapType: MapType) async {
		await MapBoxActor.shared.resetBuildingMap(mapType)
	}

	static func setBuildingMapPlayer(x: Int, y: Int) async {
		await MapBoxActor.shared.setBuildingMapPlayer(x: x, y: y)
	}

	static func setMainMapPlayerPosition(_ position: (x: Int, y: Int)) async {
		await MapBoxActor.shared.setMainMapPlayerPosition(position)
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
	case custom(mapID: UUID)

	var map: any MapBoxMap {
		get async {
			switch self {
				case .mainMap:
					await MapBoxActor.shared.mainMap!
				case .mining:
					await MapBoxActor.shared.miningMap!
				default:
					await MapBoxActor.shared.buildingMap!
			}
		}
	}
}

struct Player: Codable {
	var x: Int
	var y: Int
}
