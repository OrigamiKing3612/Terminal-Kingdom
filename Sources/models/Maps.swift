import Foundation

actor Maps {
	var customMaps: [UUID: CustomMap] = [:]
	private(set) var blacksmith: [[MapTile]] = []
	private(set) var builder: [[MapTile]] = []
	private(set) var carpenter: [[MapTile]] = []
	private(set) var castle: [[MapTile]] = []
	private(set) var farm: [[MapTile]] = []
	private(set) var hospital: [[MapTile]] = []
	private(set) var house: [[MapTile]] = []
	private(set) var hunting_area: [[MapTile]] = []
	private(set) var inventor: [[MapTile]] = []
	private(set) var mainMap: [[MapTile]] = []
	private(set) var mine: [[MapTile]] = []
	private(set) var mining: [[MapTile]] = []
	private(set) var potter: [[MapTile]] = []
	private(set) var restaurant: [[MapTile]] = []
	private(set) var shop: [[MapTile]] = []
	private(set) var stable: [[MapTile]] = []

	func updateCustomMap(id: UUID, with grid: [[MapTile]]) async {
		customMaps[id]?.updateGrid(grid)
	}

	func addMap(map: CustomMap) async {
		customMaps[map.id] = map
	}

	func removeMap(map: CustomMap) async {
		customMaps.removeValue(forKey: map.id)
	}

	func removeMap(mapID: UUID) async {
		customMaps.removeValue(forKey: mapID)
	}

	func setMap(mapType: MapType, map: [[MapTile]]) async {
		switch mapType {
			case .blacksmith:
				blacksmith = map
			case .builder:
				builder = map
			case .carpenter:
				carpenter = map
			case .castle:
				castle = map
			case let .custom(mapID: id):
				if customMaps[id] == nil {
					Logger.error("Custom Map not found (1)", code: .customMapNotFound)
				}
				customMaps[id]?.updateGrid(map)
			case .farm:
				farm = map
			case .hospital:
				hospital = map
			case .house:
				house = map
			case .hunting_area:
				hunting_area = map
			case .inventor:
				inventor = map
			case .mainMap:
				Logger.error("Main Map should not be put here (1)", code: .mainMapInMaps)
			case .mine:
				mine = map
			case .mining:
				Logger.error("Mining Map should not be put here (1)", code: .miningMapInMaps)
			case .potter:
				potter = map
			case .restaurant:
				restaurant = map
			case .shop:
				shop = map
			case .stable:
				stable = map
		}
	}

	func getMapType(mapType: MapType) async -> [[MapTile]] {
		switch mapType {
			case .blacksmith:
				blacksmith
			case .builder:
				builder
			case .carpenter:
				carpenter
			case .castle:
				castle
			case .custom:
				Logger.error("Custom Map should not be put here (2)", code: .customMapInMaps)
			case .farm:
				farm
			case .hospital:
				hospital
			case .house:
				house
			case .hunting_area:
				hunting_area
			case .inventor:
				inventor
			case .mainMap:
				Logger.error("Main Map should not be put here (2)", code: .mainMapInMaps)
			case .mine:
				mine
			case .mining:
				Logger.error("Mining Map should not be put here (2)", code: .miningMapInMaps)
			case .potter:
				potter
			case .restaurant:
				restaurant
			case .shop:
				shop
			case .stable:
				stable
		}
	}

	func updateMap(mapType: MapType, x: Int, y: Int, tile: MapTile) async {
		switch mapType {
			case .blacksmith:
				blacksmith[y][x] = tile
			case .builder:
				builder[y][x] = tile
			case .carpenter:
				carpenter[y][x] = tile
			case .castle:
				castle[y][x] = tile
			case let .custom(mapID: id):
				guard let grid = customMaps[id]?.grid else {
					Logger.error("Custom Map not found (3)", code: .customMapNotFound)
				}
				await updateCustomMap(id: id, with: grid)
			case .farm:
				farm[y][x] = tile
			case .hospital:
				hospital[y][x] = tile
			case .house:
				house[y][x] = tile
			case .hunting_area:
				hunting_area[y][x] = tile
			case .inventor:
				inventor[y][x] = tile
			case .mainMap:
				Logger.error("Main Map should not be put here (3)", code: .mainMapInMaps)
			case .mine:
				mine[y][x] = tile
			case .mining:
				Logger.error("Mining Map should not be put here (3)", code: .miningMapInMaps)
			case .potter:
				potter[y][x] = tile
			case .restaurant:
				restaurant[y][x] = tile
			case .shop:
				shop[y][x] = tile
			case .stable:
				stable[y][x] = tile
		}
	}
}
