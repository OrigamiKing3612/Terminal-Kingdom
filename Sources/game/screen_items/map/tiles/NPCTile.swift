import Foundation

struct NPCTile: Codable, Hashable, Equatable {
	let id: UUID
	let type: NPCTileType
	let canWalk: Bool
	let positionToWalkTo: TilePosition?
	var lastDirection: PlayerDirection = .allCases.randomElement()!

	init(type: NPCTileType, canWalk: Bool = false, tilePosition: NPCPosition) {
		self.id = UUID()
		self.type = type
		self.canWalk = canWalk
		self.positionToWalkTo = nil

		Task {
			await Game.shared.addNPC(tilePosition)
		}
	}

	static func renderNPC(tile: NPCTile) async -> String {
		if await !tile.type.hasTalkedToBefore {
			return "!".styled(with: [.bold, .red])
		}
		switch tile.type {
			default:
				// TODO: Not sure if this will stay
				return await (Game.shared.config.useNerdFont ? "󰙍" : "N").styled(with: .bold)
		}
	}

	var queueName: String {
		"\(type.queueName).\(id)"
	}

	func talk() async {
		switch type {
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
	}
}

extension NPCTile {
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(type, forKey: .tileType)
		try container.encode(canWalk, forKey: .canWalk)
		try container.encodeIfPresent(positionToWalkTo, forKey: .positionToWalkTo)
	}

	enum CodingKeys: CodingKey {
		case id
		case tileType
		case canWalk
		case positionToWalkTo
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.type = try container.decode(NPCTileType.self, forKey: .tileType)
		self.canWalk = try container.decode(Bool.self, forKey: .canWalk)
		self.positionToWalkTo = try container.decodeIfPresent(TilePosition.self, forKey: .positionToWalkTo)
	}
}
