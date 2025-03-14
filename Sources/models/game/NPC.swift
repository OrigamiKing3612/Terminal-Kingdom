import Foundation

struct NPC: Codable, Hashable, Equatable {
	let id: UUID
	let tileID: UUID
	let isStartingVillageNPC: Bool
	var hasTalkedToBefore: Bool
	var needsAttention: Bool

	init(id: UUID = UUID(), isStartingVillageNPC: Bool, tileID: UUID) {
		self.id = id
		self.hasTalkedToBefore = false
		self.needsAttention = false
		self.tileID = tileID
		self.isStartingVillageNPC = isStartingVillageNPC
	}

	mutating func updateTalkedTo() {
		hasTalkedToBefore = true
	}

	static func == (lhs: NPC, rhs: NPC) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
