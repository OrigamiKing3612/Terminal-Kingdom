import Foundation

protocol BuildingProtocol: Equatable, Hashable, Identifiable, Sendable {
	var id: UUID { get }
	var x: Int { get }
	var y: Int { get }
	var type: DoorTileTypes { get }

	init(id: UUID, type: DoorTileTypes, x: Int, y: Int)

	func canBeUpgraded() async -> Bool
	func getCostsForNextUpgrade() async -> [ItemAmount]?
	func upgrade() async
	func setLevel(newLevel: Int) async
	func getLevel() async -> Int
}

extension BuildingProtocol {
	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.init(id: id, type: type, x: x, y: y)
	}

	func canBeUpgraded() async -> Bool {
		guard let costs = await getCostsForNextUpgrade() else { return false }
		for cost in costs {
			if await !Game.shared.player.has(item: cost.item, count: cost.count) {
				return false
			}
		}
		return true
	}

	func upgrade() async {
		if await canBeUpgraded() {
			guard let costs = await getCostsForNextUpgrade() else { return }
			for cost in costs {
				await Game.shared.player.removeItem(item: cost.item, count: cost.count)
			}
			await setLevel(newLevel: getLevel() + 1)
		}
	}

	func getCostsForNextUpgrade() async -> [ItemAmount]? {
		let upgrades: [Int: BuildingUpgrade] = type.upgrades
		let level = await getLevel()
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
