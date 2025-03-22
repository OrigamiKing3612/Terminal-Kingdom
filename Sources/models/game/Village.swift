import Foundation

actor Village: Hashable, Identifiable, Equatable {
	let id: UUID
	var name: String
	var npcsInVillage: Set<UUID> = []
	var data: VillageData = .init()
	var hasCourthouse: Bool = false
	var courthouseID: UUID?
	private(set) var buildings: [UUID: Building] = [:]
	private(set) var radius: Int = 40

	init(id: UUID = UUID(), name: String, buildings: [Building], npcsInVillage: Set<UUID> = []) {
		self.id = id
		self.npcsInVillage = npcsInVillage
		self.buildings = Dictionary(uniqueKeysWithValues: buildings.map { ($0.id, $0) })
		self.name = name
	}

	func setHasCourthouse() {
		hasCourthouse = true
		let courthouseID = getCourthouse()?.id
		if let courthouseID {
			self.courthouseID = courthouseID
		}
	}

	func removeCourthouse() {
		hasCourthouse = false
		courthouseID = nil
	}

	func getCourthouse() -> Building? {
		buildings.values.first { $0.type == .courthouse }
	}

	func contains(x: Int, y: Int) async -> Bool {
		let center = hasCourthouse ? getCourthouse() : buildings.values.first { $0.type == .builder }
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

	func set(name: String) async {
		self.name = name
	}

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

actor VillageData {
	private(set) var courthouseStage: CourthouseStage = .notStarted

	enum CourthouseStage: String, Codable {
		case notStarted, building, gettingStuff, done
	}

	func setCourthouseStage(_ newStage: CourthouseStage) {
		courthouseStage = newStage
	}
}
