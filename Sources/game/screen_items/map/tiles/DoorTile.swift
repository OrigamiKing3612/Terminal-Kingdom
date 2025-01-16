struct DoorTile: Codable, Equatable {
	let tileType: DoorTileTypes
	let isPartOfPlayerVillage: Bool
	let isPlacedByPlayer: Bool
	private(set) var level: Int
	var hasCustomMap: Bool { isPlacedByPlayer }
	let map: [[MapTile]]?

	init(tileType: DoorTileTypes, isPartOfPlayerVillage: Bool = false, isPlacedByPlayer: Bool = false, map: [[MapTile]]? = nil) {
		self.tileType = tileType
		self.isPartOfPlayerVillage = isPartOfPlayerVillage
		level = 1
		self.isPlacedByPlayer = isPlacedByPlayer
		self.map = map
	}

	static func renderDoor(tile: DoorTile) -> String {
		let conditions: [(DoorTileTypes, Bool)] = [
			(.mine, Game.stages.blacksmith.stage1Stages == .goToMine),
			(.blacksmith, Game.stages.mine.stage1Stages == .collect),
			(.shop, Game.stages.mine.stage10Stages == .goToSalesman),
			(.carpenter, Game.stages.blacksmith.stage3Stages == .goToCarpenter),
			(.hunting_area, Game.stages.blacksmith.stage7Stages == .bringToHunter),
			(.shop, Game.stages.blacksmith.stage9Stages == .goToSalesman),
			(.mine, Game.stages.builder.stage1Stages == .collect),
		]
		if MapBox.mapType == .mainMap {
			for (doorType, condition) in conditions {
				if tile.tileType == doorType, condition {
					return "!".styled(with: [.bold, .red])
				}
			}
		}
		return "D".styled(with: .bold)
	}
}
