import Foundation

actor Village: Hashable, Identifiable, Equatable {
	let id: UUID
	var name: String
	var data: VillageData = .init()
	var hasCourthouse: Bool = false
	var courthouseID: UUID?
	private(set) var npcs: Set<UUID> = []
	private(set) var buildings: [UUID: any BuildingProtocol] = [:]
	private(set) var radius: Int = 40
	var foodCount: Int = 0
	var foodIncome: Int {
		var totalPots = 0
		let farms = buildings.values.filter { $0.type == .farm(type: .main) } as! [FarmBuilding]
		for farm in farms {
			totalPots += farm.pots
		}
		return totalPots
	}

	init(id: UUID = UUID(), name: String, buildings: [any BuildingProtocol], npcs: Set<UUID> = []) {
		self.id = id
		self.npcs = npcs
		self.buildings = Dictionary(uniqueKeysWithValues: buildings.map { ($0.id, $0) })
		self.name = name
	}

	func tick() {
		if buildings.values.contains(where: { $0.type == .farm(type: .main) }) {
			// foodCount += 1
		}
	}

	func addNPC(npcID: UUID) async {
		npcs.insert(npcID)
	}

	func removeNPC(npcID: UUID) async {
		npcs.remove(npcID)
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

	func getCourthouse() -> (any BuildingProtocol)? {
		buildings.values.first { $0.type == .courthouse }
	}

	func contains(x: Int, y: Int) async -> Bool {
		let center = hasCourthouse ? getCourthouse() : buildings.values.first { $0.type == .builder }
		guard let building = center else { return false }
		let dx = x - building.x
		let dy = y - building.y
		return dx * dx + dy * dy <= radius * radius
	}

	func add(building: any BuildingProtocol) async {
		buildings[building.id] = building
	}

	func remove(building: any BuildingProtocol) async {
		buildings.removeValue(forKey: building.id)
	}

	func remove(buildingID: UUID) async {
		buildings.removeValue(forKey: buildingID)
	}

	func set(name: String) async {
		self.name = name
		Task.detached {
			await StatusBox.statusBox()
		}
	}

	func has(npcID: UUID) -> Bool {
		npcs.contains(npcID)
	}

	func update(buildingID: UUID, newBuilding: any BuildingProtocol) async {
		buildings[buildingID] = newBuilding
	}

	func addPot(buildingID: UUID) async {
		if var building = buildings[buildingID] as? FarmBuilding {
			await building.addPot()
			buildings[buildingID] = building
		}
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
