import Foundation

struct NPC: Codable, Hashable, Equatable {
	let id: UUID
	let name: String
	let isStartingVillageNPC: Bool
	var hasTalkedToBefore: Bool
	var needsAttention: Bool
	var job: NPCJob?
	// let age: Int
	let gender: Gender
	private(set) var positionToWalkTo: TilePosition?

	init(id: UUID = UUID(), name: String? = nil /* , age: Int? = nil */, gender: Gender? = nil, job: NPCJob? = nil, isStartingVillageNPC: Bool = false, positionToWalkTo: TilePosition? = nil) {
		self.id = id
		self.gender = gender ?? Gender.allCases.randomElement()!
		self.name = name ?? Self.generateRandomName(for: self.gender)
		// self.age = age ?? Int.random(in: 18 ... 80)
		self.job = job
		self.isStartingVillageNPC = isStartingVillageNPC
		self.hasTalkedToBefore = false
		self.needsAttention = false
		self.positionToWalkTo = positionToWalkTo
	}

	mutating func removePostion() {
		positionToWalkTo = nil
	}

	static func generateRandomName(for gender: Gender) -> String {
		let maleNames = [
			"Adam", "Ben", "Caleb", "Daniel", "Eric",
			"Felix", "Greg", "Henry", "Isaac", "Jack",
			"Kyle", "Leo", "Matt", "Nate", "Owen",
			"Paul", "Quinn", "Ryan", "Sam", "Tom",
			"Victor", "Theo", "Jim", "Eli", "Mark",
		]

		let femaleNames = [
			"Anna", "Beth", "Chloe", "Daisy", "Emma",
			"Faith", "Grace", "Hannah", "Ivy", "Julia",
			"Kate", "Lily", "Mia", "Nora", "Olivia",
			"Paige", "Jordan", "Rachel", "Sarah", "Tessa",
			"Violet", "Wendy", "Zoey", "Ellie", "Claire",
		]

		return (gender == .male ? maleNames : femaleNames).randomElement()!
	}

	mutating func updateTalkedTo() {
		hasTalkedToBefore = true
	}

	static func setTalkedTo(after: @escaping @Sendable () async -> Void) async {
		let mapTile = await MapBox.tilePlayerIsOn
		guard case let .npc(tile: tile) = mapTile.type else {
			return
		}
		if tile.npc.hasTalkedToBefore == false {
			var newTile = tile
			newTile.npc.updateTalkedTo()
			let newMapTile = MapTile(type: .npc(tile: newTile), isWalkable: mapTile.isWalkable, event: mapTile.event, biome: mapTile.biome)
			await MapBox.updateTile(newTile: newMapTile)
			await after()
		}
	}

	static func setTalkedTo() async {
		await setTalkedTo(after: {})
	}

	static func == (lhs: NPC, rhs: NPC) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	func talk() async {
		if let job, isStartingVillageNPC {
			switch job {
				case .blacksmith:
					await BlacksmithNPC.talk()
				case .blacksmith_helper:
					await BlacksmithHelperNPC.talk()
				case .miner:
					await MinerNPC.talk()
				case .mine_helper:
					await MineHelperNPC.talk()
				case .carpenter:
					await CarpenterNPC.talk()
				case .carpenter_helper:
					await CarpenterHelperNPC.talk()
				case .king:
					await KingNPC.talk()
				case .salesman:
					await SalesmanNPC.talk()
				case .builder:
					await BuilderNPC.talk()
				case .builder_helper:
					await BuilderHelperNPC.talk()
				case .hunter:
					await HunterNPC.talk()
				case .inventor:
					break
				case .stable_master:
					break
				case .farmer:
					await FarmerNPC.talk()
				case .doctor:
					break
				case .chef:
					break
				case .potter:
					await PotterNPC.talk()
				case .farmer_helper:
					await FarmerHelperNPC.talk()
			}
		} else {
			await MessageBox.message("Hello!", speaker: .npc(name: name, job: job))
		}
	}
}

enum Gender: String, Codable, CaseIterable {
	case male, female
}
