import Foundation

actor StartingVillage: Hashable, Equatable {
	nonisolated var id: UUID {
		NPCTile.startingVillageID
	}

	private(set) var npcJobs: [NPCJob: UUID] = [:]
	private(set) var npcs: [UUID: NPC] = [:]

	init() {}

	func setUp() async {
		Logger.debug("Setting up starting village")
		func getXY(for mapType: MapType, isNPCJob: (NPCTile) -> Bool) async -> (Int, Int) {
			let buildingMap: [[MapTile]] = await StaticMaps.buildingMap(mapType: mapType)

			for (y, row) in buildingMap.enumerated() {
				for (x, tile) in row.enumerated() {
					if case let .npc(tile: npc) = tile.type {
						if isNPCJob(npc) {
							return (x, y)
						}
					}
				}
			}
			return (0, 0)
		}
		var npcs: [UUID: NPC] = [:]
		for job in [NPCJob.blacksmith, .blacksmith_helper, .miner, .mine_helper, .carpenter, .carpenter_helper, .farmer, .farmer_helper, .king, .salesman(type: .buy), .salesman(type: .sell), .salesman(type: .help), .builder, .builder_helper, .hunter, .inventor, .stable_master, .doctor, .chef, .potter] {
			let id = UUID()
			let (x, y) = await getXY(for: job.toMapType) { _ in
				true
			}
			npcs[id] = NPC(id: id, job: job, villageID: id, position: .init(x: x, y: y, mapType: job.toMapType))
			npcJobs[job] = id
		}
		// npcs[.blacksmith_helper] = NPC(id: UUID(), job: .blacksmith_helper, villageID: id, position: .init(x: x, y: y, mapType: .blacksmith))
		// npcs[.miner] = NPC(id: UUID(), job: .miner, villageID: id, position: .init(x: x, y: y, mapType: .mine))
		// npcs[.mine_helper] = NPC(id: UUID(), job: .mine_helper, villageID: id, position: .init(x: x, y: y, mapType: .mine))
		// npcs[.carpenter] = NPC(id: UUID(), job: .carpenter, villageID: id, position: .init(x: x, y: y, mapType: .carpenter))
		// npcs[.carpenter_helper] = NPC(id: UUID(), job: .carpenter_helper, villageID: id, position: .init(x: x, y: y, mapType: .carpenter))
		// npcs[.farmer] = NPC(id: UUID(), job: .farmer, villageID: id, position: .init(x: x, y: y, mapType: .farm(type: .main)))
		// npcs[.farmer_helper] = NPC(id: UUID(), job: .farmer_helper, villageID: id, position: .init(x: x, y: y, mapType: .farm(type: .main)))
		// npcs[.king] = NPC(id: UUID(), job: .king, villageID: id, position: .init(x: x, y: y, mapType: .castle(side: .top)))
		// npcs[.salesman(type: .buy)] = NPC(id: UUID(), job: .salesman(type: .buy), villageID: id, position: .init(x: x, y: y, mapType: .shop))
		// npcs[.salesman(type: .sell)] = NPC(id: UUID(), job: .salesman(type: .sell), villageID: id, position: .init(x: x, y: y, mapType: .shop))
		// npcs[.salesman(type: .help)] = NPC(id: UUID(), job: .salesman(type: .help), villageID: id, position: .init(x: x, y: y, mapType: .shop))
		// npcs[.builder] = NPC(id: UUID(), job: .builder, villageID: id, position: .init(x: x, y: y, mapType: .builder))
		// npcs[.builder_helper] = NPC(id: UUID(), job: .builder_helper, villageID: id, position: .init(x: x, y: y, mapType: .builder))
		// npcs[.hunter] = NPC(id: UUID(), job: .hunter, villageID: id, position: .init(x: x, y: y, mapType: .hunting_area))
		// npcs[.inventor] = NPC(id: UUID(), job: .inventor, villageID: id, position: .init(x: x, y: y, mapType: .inventor))
		// npcs[.stable_master] = NPC(id: UUID(), job: .stable_master, villageID: id, position: .init(x: x, y: y, mapType: .stable))
		// npcs[.doctor] = NPC(id: UUID(), job: .doctor, villageID: id, position: .init(x: x, y: y, mapType: .hospital(side: .top)))
		// npcs[.chef] = NPC(id: UUID(), job: .chef, villageID: id, position: .init(x: x, y: y, mapType: .restaurant))
		// npcs[.potter] = NPC(id: UUID(), job: .potter, villageID: id, position: .init(x: x, y: y, mapType: .potter))
		self.npcs = npcs
	}

	func getNPCs() -> [NPC] {
		Array(npcs.values)
	}

	func getNPC(for position: NPCPosition) -> NPC? {
		npcs.values.first { $0.position == position }
	}

	// func add(npc: NPC) async {
	// 	npcs[npc.id] = npc
	// }
	//
	// func remove(npc: NPC) async {
	// 	npcs.removeValue(forKey: npc.id)
	// }
	//
	// func remove(npcID: UUID) async {
	// 	npcs.removeValue(forKey: npcID)
	// }
	//
	// func removeNPCPosition(npcID: UUID) async {
	// 	npcs[npcID]?.removePostion()
	// }

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

extension NPCJob {
	var toMapType: MapType {
		switch self {
			case .blacksmith:
				.blacksmith
			case .blacksmith_helper:
				.blacksmith
			case .builder:
				.builder
			case .builder_helper:
				.builder
			case .carpenter:
				.carpenter
			case .carpenter_helper:
				.carpenter
			case .chef:
				.restaurant
			case .doctor:
				.hospital(side: .top)
			case .farmer:
				.farm(type: .main)
			case .farmer_helper:
				.farm(type: .main)
			case .hunter:
				.hunting_area
			case .inventor:
				.inventor
			case .king:
				.castle(side: .top)
			case .mine_helper:
				.mine
			case .miner:
				.mine
			case .potter:
				.potter
			case .salesman:
				.shop
			case .stable_master:
				.stable
		}
	}
}
