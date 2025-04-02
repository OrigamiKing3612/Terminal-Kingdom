import Foundation

actor StartingVillage: Hashable, Equatable {
	nonisolated var id: UUID {
		NPCTile.startingVillageID
	}

	private(set) var npcs: [UUID: NPC] = [:]

	init() {}

	func setUp() async {
		Logger.debug("Setting up starting village")
		var npcs: [UUID: NPC] = [:]
		for file in MapFileName.allCases {
			let mapType = StaticMaps.fileNameToMapType(fileName: file)
			let buildingMap = await StaticMaps.buildingMap(mapType: mapType) // [[MapTile]]

			for (y, row) in buildingMap.enumerated() {
				for (x, tile) in row.enumerated() {
					if case let .npc(tile: npc) = tile.type {
						let job: NPCJob? = switch mapType {
							case .blacksmith:
								.blacksmith
							case .builder:
								.builder
							case .carpenter:
								.carpenter
							case .castle:
								.king
							case .farm:
								.farmer
							case .hospital:
								.doctor
							case .hunting_area:
								.hunter
							case .inventor:
								.inventor
							case .mine:
								.miner
							case .potter:
								.potter
							case .restaurant:
								.chef
							case .shop:
								.salesman(type: .buy)
							case .stable:
								.stable_master
							default:
								nil
						}
						npcs[npc.npcID] = NPC(id: npc.npcID, job: job, villageID: id, position: .init(x: x, y: y, mapType: mapType))
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
