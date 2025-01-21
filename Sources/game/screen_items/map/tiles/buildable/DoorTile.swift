import Foundation

struct DoorTile: BuildableTile, Hashable {
	let type: DoorTileTypes
	let isPartOfPlayerVillage: Bool
	let isPlacedByPlayer: Bool
	private(set) var level: Int
	var hasCustomMap: Bool { isPlacedByPlayer }

	init(type: DoorTileTypes, isPartOfPlayerVillage: Bool = false, isPlacedByPlayer: Bool = false) {
		self.type = type
		self.isPartOfPlayerVillage = isPartOfPlayerVillage
		level = 1
		self.isPlacedByPlayer = isPlacedByPlayer
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
				if tile.type == doorType, condition {
					return "!".styled(with: [.bold, .red])
				}
			}
		}
		return "D".styled(with: .bold)
	}
}

extension DoorTile {
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		type = try container.decode(DoorTileTypes.self, forKey: .tileType)
		isPartOfPlayerVillage = try container.decode(Bool.self, forKey: .isPartOfPlayerVillage)
		isPlacedByPlayer = try container.decode(Bool.self, forKey: .isPlacedByPlayer)
		level = try container.decode(Int.self, forKey: .level)
	}

	enum CodingKeys: CodingKey {
		case tileType
		case isPartOfPlayerVillage
		case isPlacedByPlayer
		case level
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(type, forKey: .tileType)
		try container.encode(isPartOfPlayerVillage, forKey: .isPartOfPlayerVillage)
		try container.encode(isPlacedByPlayer, forKey: .isPlacedByPlayer)
		try container.encode(level, forKey: .level)
	}
}
