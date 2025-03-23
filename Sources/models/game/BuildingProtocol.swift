import Foundation

protocol BuildingProtocol: Codable, Equatable, Hashable, Identifiable {
	var id: UUID { get }
	var x: Int { get }
	var y: Int { get }
	var type: DoorTileTypes { get }
	var level: Int { get set }

	init(id: UUID, type: DoorTileTypes, x: Int, y: Int)

	func canBeUpgraded() async -> Bool
	func getCostsForNextUpgrade() -> [ItemAmount]?
	mutating func upgrade() async
}

extension BuildingProtocol {
	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.init(id: id, type: type, x: x, y: y)
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

	mutating func upgrade() async {
		if await canBeUpgraded() {
			guard let costs = getCostsForNextUpgrade() else { return }
			for cost in costs {
				await Game.shared.player.removeItem(item: cost.item, count: cost.count)
			}
			level += 1
		}
	}

	func getCostsForNextUpgrade() -> [ItemAmount]? {
		let upgrades: [Int: BuildingUpgrade] = type.upgrades
		guard let upgrade = upgrades[level + 1] else {
			return nil
		}
		return upgrade.cost
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
