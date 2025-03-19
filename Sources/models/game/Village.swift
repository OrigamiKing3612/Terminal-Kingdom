import Foundation

actor Village: Hashable, Identifiable, Equatable {
	let id: UUID
	var name: String
	private(set) var buildings: [UUID: Building] = [:]
	var npcsInVillage: Set<UUID> = []
	var hasCastle: Bool = false
	var data: [VillageData] = []
	private(set) var radius: Int = 40
	// TODO: make the village have its own center
	var castleID: UUID?

	init(id: UUID = UUID(), name: String, buildings: [Building], npcsInVillage: Set<UUID> = []) {
		self.id = id
		self.npcsInVillage = npcsInVillage
		self.buildings = Dictionary(uniqueKeysWithValues: buildings.map { ($0.id, $0) })
		self.name = name
	}

	func addData(_ data: VillageData) {
		self.data.append(data)
	}

	func removeData(_ data: VillageData) {
		self.data.removeAll { $0 == data }
	}

	func setHasCastle() {
		hasCastle = true
		let castleID = getCastle()?.id
		if let castleID {
			self.castleID = castleID
		}
	}

	func removeCastle() {
		hasCastle = false
		castleID = nil
	}

	func getCastle() -> Building? {
		buildings.values.first { $0.type == .castle(side: .top) }
	}

	func contains(x: Int, y: Int) async -> Bool {
		let center = hasCastle ? getCastle() : buildings.values.first { $0.type == .builder }
		guard let building = center else { return false }
		let dx = x - building.x
		let dy = y - building.y
		return dx * dx + dy * dy <= radius * radius
	}

	func add(building: Building) async {
		buildings[building.id] = building
	}

	func remove(building: Building) async {
		buildings.removeValue(forKey: building.id)
	}

	func remove(buildingID: UUID) async {
		buildings.removeValue(forKey: buildingID)
	}

	func add(npc: NPC) async {
		npcsInVillage.insert(npc.id)
	}

	func add(npc: UUID) async {
		npcsInVillage.insert(npc)
	}

	func remove(npc: NPC) async {
		npcsInVillage.remove(npc.id)
	}

	func remove(npcID: UUID) async {
		npcsInVillage.remove(npcID)
	}

	func add(data: VillageData) async {
		self.data.append(data)
	}

	func remove(data: VillageData) async {
		self.data.removeAll { $0 == data }
	}

	func set(name: String) async {
		self.name = name
	}

	// func getIndex(npc: UUID) async -> Int? {
	// 	npcsInVillage.firstIndex(of: npc)
	// }

	func has(npcID: UUID) -> Bool {
		npcsInVillage.contains(npcID)
	}

	func update(buildingID: UUID, newBuilding: Building) async {
		buildings[buildingID] = newBuilding
	}

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: Village, rhs: Village) -> Bool {
		lhs.id == rhs.id
	}
}

enum VillageData: Codable, Hashable {
	case buildingCastle, gettingStuffToBuildCastle
}
