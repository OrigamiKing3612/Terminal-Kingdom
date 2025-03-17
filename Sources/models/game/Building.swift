import Foundation

struct Building: Codable, Equatable, Hashable, Identifiable {
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
		let upgrades: [Int: BuildingUpgrade] = type.upgrades
		guard !upgrades.isEmpty else {
			return false
		}
		guard let upgrade = upgrades[level + 1] else {
			return false
		}
		let costs = upgrade.cost
		for cost in costs {
			if await !Game.shared.player.has(item: cost.item, count: cost.count) {
				return false
			}
		}
		return true
	}

	mutating func upgrade() async {
		if await canBeUpgraded() {
			let upgrades: [Int: BuildingUpgrade] = type.upgrades
			guard let upgrade = upgrades[level + 1] else {
				return
			}
			let costs = upgrade.cost
			for cost in costs {
				await Game.shared.player.removeItem(item: cost.item, count: cost.count)
			}
			level += 1
		}
	}
}
