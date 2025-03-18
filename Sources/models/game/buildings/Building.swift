import Foundation

class Building: Codable, Equatable, Hashable, Identifiable, @unchecked Sendable {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	private(set) var level: Int

	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.id = id
		self.type = type
		self.level = 1
		self.x = x
		self.y = y
	}

	func canBeUpgraded() async -> Bool {
		guard let costs = getCostsForNextUpgrade() else { return false }
		for cost in costs {
			if await !Game.shared.player.has(item: cost.item, count: cost.count) {
				return false
			}
		}
		return true
	}

	func upgrade() async {
		if await canBeUpgraded() {
			guard let costs = getCostsForNextUpgrade() else { return }
			for cost in costs {
				await Game.shared.player.removeItem(item: cost.item, count: cost.count)
			}
			level += 1
		}
	}

	private func getCostsForNextUpgrade() -> [ItemAmount]? {
		let upgrades: [Int: BuildingUpgrade] = type.upgrades
		guard let upgrade = upgrades[level + 1] else {
			return nil
		}
		return upgrade.cost
	}

	static func == (lhs: Building, rhs: Building) -> Bool {
		lhs.id == rhs.id
	}

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	enum CodingKeys: CodingKey {
		case id
		case x
		case y
		case type
		case level
	}

	required init(from decoder: any Decoder) throws {
		let container: KeyedDecodingContainer<Building.CodingKeys> = try decoder.container(keyedBy: Building.CodingKeys.self)

		self.id = try container.decode(UUID.self, forKey: Building.CodingKeys.id)
		self.x = try container.decode(Int.self, forKey: Building.CodingKeys.x)
		self.y = try container.decode(Int.self, forKey: Building.CodingKeys.y)
		self.type = try container.decode(DoorTileTypes.self, forKey: Building.CodingKeys.type)
		self.level = try container.decode(Int.self, forKey: Building.CodingKeys.level)
	}

	func encode(to encoder: any Encoder) throws {
		var container: KeyedEncodingContainer<Building.CodingKeys> = encoder.container(keyedBy: Building.CodingKeys.self)

		try container.encode(id, forKey: Building.CodingKeys.id)
		try container.encode(x, forKey: Building.CodingKeys.x)
		try container.encode(y, forKey: Building.CodingKeys.y)
		try container.encode(type, forKey: Building.CodingKeys.type)
		try container.encode(level, forKey: Building.CodingKeys.level)
	}
}
