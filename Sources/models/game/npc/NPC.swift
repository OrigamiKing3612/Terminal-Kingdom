import Foundation

struct NPC: Codable, Hashable, Equatable {
	let id: UUID
	let name: String
	let isStartingVillageNPC: Bool
	var hasTalkedToBefore: Bool
	var job: NPCJob?
	// skill level
	let age: Int
	let gender: Gender
	let villageID: UUID?
	private(set) var positionToWalkTo: TilePosition?
	private(set) var attributes: [NPCAttribute] = []
	private var _hunger: Double = 100
	private var hunger: Hunger { Hunger.hunger(for: _hunger) }

	init(id: UUID = UUID(), name: String? = nil, gender: Gender? = nil, job: NPCJob? = nil, isStartingVillageNPC: Bool = false, positionToWalkTo: TilePosition? = nil, tilePosition: NPCPosition? = nil, villageID: UUID, age: Int = Int.random(in: 18 ... 40)) {
		self.id = id
		self.gender = gender ?? Gender.allCases.randomElement()!
		self.name = name ?? Self.generateRandomName(for: self.gender)
		self.job = job
		self.isStartingVillageNPC = isStartingVillageNPC
		self.hasTalkedToBefore = false
		if let tilePosition {
			self.positionToWalkTo = positionToWalkTo
			Task {
				await Game.shared.addNPC(tilePosition)
			}
		}
		Task {
			await Game.shared.kingdom.add(npcID: id, villageID: villageID)
		}
		self.villageID = villageID
		self.age = age
	}

	mutating func tick() async {
		// TODO: remove npc
		guard let villageID else { return }
		// guard let kingdom = await Game.shared.getKingdom(id: villageID) else { return }
		_hunger -= 0.1

		if _hunger <= 0 {
			// if let positionToWalkTo {
			// await Game.shared.removeNPC()
			// }
			await Game.shared.kingdom.villages[villageID]?.remove(npcID: id)
		}
	}

	mutating func setHunger(_ newHunger: Double) {
		_hunger = newHunger
	}

	mutating func removePostion() {
		positionToWalkTo = nil
	}

	mutating func addAttribute(_ attribute: NPCAttribute) {
		attributes.append(attribute)
	}

	mutating func removeAttribute(_ attribute: NPCAttribute) {
		attributes.removeAll { $0 == attribute }
	}

	static func generateRandomName(for gender: Gender) -> String {
		let maleNames = [
			"Adam", "Ben", "Caleb", "Daniel", "Eric",
			"Felix", "Greg", "Craig", "Isaac", "Jack",
			"Kyle", "Leo", "Matt", "Nate", "Owen",
			"Paul", "Quinn", "Ryan", "Sam", "Tom",
			"Victor", "Theo", "Jim", "Eli", "Mark",
			"John", "David", "Michael", "James", "Robert",
			"Alexander", "Fred", "Garrett", "Charles", "John",
			"William", "Henry", "George", "Edward", "Thomas",
			"Joseph", "Frank", "Patrick", "Peter", "Simon",
			"Nathaniel", "Ethan", "Luke", "Josh", "Liam",
		]

		let femaleNames = [
			"Anna", "Beth", "Chloe", "Daisy", "Emma",
			"Faith", "Grace", "Hannah", "Ivy", "Julia",
			"Kate", "Lily", "Mia", "Nora", "Olivia",
			"Paige", "Jordan", "Rachel", "Sarah", "Tessa",
			"Violet", "Wendy", "Zoey", "Ellie", "Claire",
			"Emily", "Haley", "Isabel", "Katie", "Lila",
			"Maggie", "Natalie", "Olivia", "Piper", "Hannah",
			"Rebecca", "Sophie", "Tara", "Ursula", "Vivian",
			"Caroline", "Alice", "Lily", "Taylor", "Megan",
			"Ava", "Sophia", "Amelia", "Harper", "Evelyn",
		]

		return (gender == .male ? maleNames : femaleNames).randomElement()!
	}

	mutating func updateTalkedTo() {
		hasTalkedToBefore = true
	}

	static func setTalkedTo(after: @escaping () async -> Void) async {
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
		if let job {
			if isStartingVillageNPC {
				switch job {
					case .blacksmith:
						await SVBlacksmithNPC.talk()
					case .blacksmith_helper:
						await SVBlacksmithHelperNPC.talk()
					case .miner:
						await SVMinerNPC.talk()
					case .mine_helper:
						await SVMineHelperNPC.talk()
					case .carpenter:
						await SVCarpenterNPC.talk()
					case .carpenter_helper:
						await SVCarpenterHelperNPC.talk()
					case .king:
						await SVKingNPC.talk()
					case .salesman:
						await SVSalesmanNPC.talk()
					case .builder:
						await SVBuilderNPC.talk()
					case .builder_helper:
						await SVBuilderHelperNPC.talk()
					case .hunter:
						await SVHunterNPC.talk()
					case .inventor:
						break
					case .stable_master:
						break
					case .farmer:
						await SVFarmerNPC.talk()
					case .doctor:
						break
					case .chef:
						break
					case .potter:
						await SVPotterNPC.talk()
					case .farmer_helper:
						await SVFarmerHelperNPC.talk()
				}
			} else {
				switch job {
					case .builder:
						await BuilderNPC.talk(npc: self)
					default:
						break
				}
			}
		}
	}

	private enum CodingKeys: CodingKey {
		case id
		case name
		case isStartingVillageNPC
		case hasTalkedToBefore
		case job
		case age
		case gender
		case villageID
		case positionToWalkTo
		case attributes
		case hunger
	}

	init(from decoder: any Decoder) throws {
		let container: KeyedDecodingContainer<NPC.CodingKeys> = try decoder.container(keyedBy: NPC.CodingKeys.self)

		self.id = try container.decode(UUID.self, forKey: NPC.CodingKeys.id)
		self.name = try container.decode(String.self, forKey: NPC.CodingKeys.name)
		self.isStartingVillageNPC = try container.decode(Bool.self, forKey: NPC.CodingKeys.isStartingVillageNPC)
		self.hasTalkedToBefore = try container.decode(Bool.self, forKey: NPC.CodingKeys.hasTalkedToBefore)
		self.job = try container.decodeIfPresent(NPCJob.self, forKey: NPC.CodingKeys.job)
		self.age = try container.decode(Int.self, forKey: NPC.CodingKeys.age)
		self.gender = try container.decode(Gender.self, forKey: NPC.CodingKeys.gender)
		self.villageID = try container.decodeIfPresent(UUID.self, forKey: NPC.CodingKeys.villageID)
		self.positionToWalkTo = try container.decodeIfPresent(TilePosition.self, forKey: NPC.CodingKeys.positionToWalkTo)
		self.attributes = try container.decode([NPCAttribute].self, forKey: NPC.CodingKeys.attributes)
		self._hunger = try container.decode(Double.self, forKey: NPC.CodingKeys.hunger)
	}

	func encode(to encoder: any Encoder) throws {
		var container: KeyedEncodingContainer<NPC.CodingKeys> = encoder.container(keyedBy: NPC.CodingKeys.self)

		try container.encode(id, forKey: NPC.CodingKeys.id)
		try container.encode(name, forKey: NPC.CodingKeys.name)
		try container.encode(isStartingVillageNPC, forKey: NPC.CodingKeys.isStartingVillageNPC)
		try container.encode(hasTalkedToBefore, forKey: NPC.CodingKeys.hasTalkedToBefore)
		try container.encodeIfPresent(job, forKey: NPC.CodingKeys.job)
		try container.encode(age, forKey: NPC.CodingKeys.age)
		try container.encode(gender, forKey: NPC.CodingKeys.gender)
		try container.encodeIfPresent(villageID, forKey: NPC.CodingKeys.villageID)
		try container.encodeIfPresent(positionToWalkTo, forKey: NPC.CodingKeys.positionToWalkTo)
		try container.encode(attributes, forKey: NPC.CodingKeys.attributes)
		try container.encode(_hunger, forKey: NPC.CodingKeys.hunger)
	}
}

enum Gender: String, Codable, CaseIterable {
	case male, female
}

enum NPCAttribute: Codable, CaseIterable {
	case needsAttention
}

enum Hunger: Codable, CaseIterable {
	case starving
	case hungry
	case could_eat
	case full

	var name: String {
		switch self {
			case .starving:
				"Starving"
			case .hungry:
				"Hungry"
			case .could_eat:
				"Could Eat"
			case .full:
				"Full"
		}
	}

	static func hunger(for hunger: Double) -> Hunger {
		switch hunger {
			case 0 ..< 25:
				.starving
			case 25 ..< 50:
				.hungry
			case 50 ..< 75:
				.could_eat
			case 75 ..< 100:
				.full
			default:
				.full
		}
	}
}
