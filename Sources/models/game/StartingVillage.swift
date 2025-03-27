import Foundation

actor StartingVillage: Hashable, Identifiable, Equatable {
	let id: UUID
	private(set) var npcs: [UUID: NPC] = [:]

	init(id: UUID = UUID()) {
		self.id = id
	}

	func setUp() async {
		Logger.debug("Setting up starting village")
		var npcs: [UUID: NPC] = [:]
		for file in MapFileName.allCases {
			let mapType = StaticMaps.fileNameToMapType(fileName: file)
			let buildingMap = await StaticMaps.buildingMap(mapType: mapType) // [[MapTile]]

			for (y, row) in buildingMap.enumerated() {
				for (x, tile) in row.enumerated() {
					if case let .npc(tile: npc) = tile.type {
						npcs[npc.id] = NPC(id: npc.id, villageID: id, position: .init(x: x, y: y, mapType: mapType))
					}
				}
			}
		}
		self.npcs = npcs
	}

	func getNPCs() -> [NPC] {
		Array(npcs.values)
	}

	func getNPC(for position: NPCPosition) -> NPC? {
		npcs.values.first { $0.position == position }
	}

	func add(npc: NPC) async {
		npcs[npc.id] = npc
	}

	func remove(npc: NPC) async {
		npcs.removeValue(forKey: npc.id)
	}

	func remove(npcID: UUID) async {
		npcs.removeValue(forKey: npcID)
	}

	func removeNPCPosition(npcID: UUID) async {
		npcs[npcID]?.removePostion()
	}

	func has(npcID: UUID) -> Bool {
		npcs[npcID] != nil
	}

	func set(npc: NPC) async {
		npcs[npc.id] = npc
	}

	func setTalkedTo(npcID: UUID) async {
		npcs[npcID]?.updateTalkedTo()
	}

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: StartingVillage, rhs: StartingVillage) -> Bool {
		lhs.id == rhs.id
	}
}
