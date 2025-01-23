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
		var map = mainMap!
		await map.updateTile(newTile: newTile)
		mainMap = map
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
}
