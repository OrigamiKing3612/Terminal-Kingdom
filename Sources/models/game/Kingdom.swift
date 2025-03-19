import Foundation

actor Kingdom: Hashable, Equatable, Identifiable {
	let id: UUID
	var name: String
	private(set) var villages: [UUID: Village] = [:]

	init(id: UUID = UUID()) {
		self.id = id
		self.name = "Kingdom"
		Task {
			await self.set(name: "\(Game.shared.player.name)'s Kingdom")
		}
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

	func add(building: Building, villageID: UUID) async {
		await villages[villageID]?.add(building: building)
	}

	func add(npcID: UUID, villageID: UUID) async {
		await villages[villageID]?.add(npc: npcID)
	}

	func addVillageData(_ data: VillageData, npcInVillage: UUID) async {
		for village in villages.values {
			if await village.has(npcID: npcInVillage) {
				await village.add(data: data)
				break
			}
		}
	}

	func removeVillageData(_ data: VillageData, npcInVillage: UUID) async {
		for village in villages.values {
			if await village.has(npcID: npcInVillage) {
				await village.remove(data: data)
				break
			}
		}
	}

	func setVillageCastle(villageID: UUID) async {
		await villages[villageID]?.setHasCastle()
	}

	func removeVillageCastle(villageID: UUID) async {
		await villages[villageID]?.removeCastle()
	}

	func getVillageCastle(villageID: UUID) async -> Building? {
		await villages[villageID]?.getCastle()
	}

	func isInsideVillage(x: Int, y: Int) async -> UUID? {
		for village in villages.values where await village.contains(x: x, y: y) {
			return village.id
		}
		return nil
	}

	func getVillageBuilding(for npc: NPC, villageID: UUID) async -> Building? {
		await villages[villageID]?.buildings.values.first { $0.id == npc.id }
	}

	func getVillageBuilding(for npc: NPC) async -> Building? {
		for village in villages.values {
			if await village.npcsInVillage.contains(npc.id) {
				return await village.buildings.values.first { $0.id == npc.id }
			}
		}
		return nil
	}

	func hasVillageBuilding(x: Int, y: Int) async -> Building? {
		for village in villages.values {
			for building in await village.buildings.values {
				if building.x == x, building.y == y {
					return building
				}
			}
		}
		return nil
	}

	func updateVillageBuilding(villageID: UUID, buildingID: UUID, newBuilding: Building) async {
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
			if await village.npcsInVillage.contains(npc.id) {
				return village
			}
		}
		return nil
	}

	func renameVillage(id: UUID, name: String) async {
		await villages[id]?.set(name: name)
	}

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: Kingdom, rhs: Kingdom) -> Bool {
		lhs.id == rhs.id
	}
}
