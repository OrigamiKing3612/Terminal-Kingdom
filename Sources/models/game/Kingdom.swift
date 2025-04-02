import Foundation

actor Kingdom: Hashable, Equatable, Identifiable {
	let id: UUID
	var name: String
	var hasCastle: Bool { castle != nil }
	var castle: Building?
	var data: KingdomData = .init()
	private(set) var villages: [UUID: Village] = [:]

	init(id: UUID = UUID()) {
		self.id = id
		self.name = "Kingdom"
	}

	func create(village: Village) async {
		villages[village.id] = village
	}

	func remove(village: Village) async {
		villages.removeValue(forKey: village.id)
	}

	func get(villageID: UUID) async -> Village? {
		villages[villageID]
	}

	func set(name: String) async {
		self.name = name
	}

	func add(building: any BuildingProtocol, villageID: UUID) async {
		await villages[villageID]?.add(building: building)
	}

	func add(npc: NPC, villageID: UUID) async {
		await villages[villageID]?.add(npc: npc)
	}

	func set(castle: Building) {
		self.castle = castle
	}

	func setNPC(villageID: UUID, npc: NPC) async {
		await villages[villageID]?.set(npc: npc)
	}

	func removeCastle() {
		castle = nil
	}

	func setVillageCourthouse(villageID: UUID) async {
		await villages[villageID]?.setHasCourthouse()
	}

	func removeVillageCourthouse(villageID: UUID) async {
		await villages[villageID]?.removeCourthouse()
	}

	func getVillageCourthouse(villageID: UUID) async -> (any BuildingProtocol)? {
		await villages[villageID]?.getCourthouse()
	}

	func isInsideVillage(x: Int, y: Int) async -> UUID? {
		for village in villages.values where await village.contains(x: x, y: y) {
			return village.id
		}
		return nil
	}

	func getVillageBuilding(for npc: NPC, villageID: UUID) async -> (any BuildingProtocol)? {
		await villages[villageID]?.buildings.values.first { $0.id == npc.id }
	}

	func getVillageBuilding(for npc: NPC) async -> (any BuildingProtocol)? {
		for village in villages.values {
			if await village.npcs.contains(where: { $0.key == npc.id }) {
				return await village.buildings.values.first { $0.id == npc.id }
			}
		}
		return nil
	}

	func hasVillageBuilding(x: Int, y: Int) async -> (any BuildingProtocol)? {
		for village in villages.values {
			for building in await village.buildings.values {
				if building.x == x, building.y == y {
					return building
				}
			}
		}
		return nil
	}

	func updateVillageBuilding(villageID: UUID, buildingID: UUID, newBuilding: any BuildingProtocol) async {
		await villages[villageID]?.update(buildingID: buildingID, newBuilding: newBuilding)
	}

	func getVillage(buildingID: UUID) async -> Village? {
		for village in villages.values {
			if await village.buildings[buildingID] != nil {
				return village
			}
		}
		return nil
	}

	func getVillage(for npc: NPC) async -> Village? {
		for village in villages.values {
			if await village.npcs.contains(where: { $0.key == npc.id }) {
				return village
			}
		}
		return nil
	}

	func getVillage(npcID: UUID) async -> Village? {
		for village in villages.values {
			if await village.npcs.contains(where: { $0.key == npcID }) {
				return village
			}
		}
		return nil
	}

	func renameVillage(id: UUID, name: String) async {
		await villages[id]?.set(name: name)
	}

	func getNPC(for position: NPCPosition) async -> NPC? {
		if let villageID = await isInsideVillage(x: position.x, y: position.y) {
			return await villages[villageID]?.getNPC(for: position)
		} else {
			for village in villages {
				if let npc = await village.value.getNPC(for: position) {
					return npc
				}
			}
		}
		return nil
	}

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: Kingdom, rhs: Kingdom) -> Bool {
		lhs.id == rhs.id
	}
}

actor KingdomData {
	private(set) var castleStage: CastleStages = .notStarted

	enum CastleStages: CaseIterable, Hashable, Equatable {
		case notStarted
		case gettingStuff
		case building
		case done
	}

	func setCastleStage(_ newStage: CastleStages) {
		castleStage = newStage
	}
}

#if DEBUG
	extension Kingdom {
		var print: String {
			get async {
				let villagesPrint = await villages.values.asyncMap { await "\($0.print)" }.joined(separator: ", ")
				return "Kingdom(id: \(id), name: \(name), hasCastle: \(hasCastle), castle: \(String(describing: castle)), villages: [\(villagesPrint)])"
			}
		}
	}

	extension Village {
		var print: String {
			get async {
				"Village(id: \(id), name: \(name), buildings: [\(buildings.values.map { "\($0)" }.joined(separator: ", "))], npcs: \(npcs), data: \(data))"
			}
		}
	}
#endif
