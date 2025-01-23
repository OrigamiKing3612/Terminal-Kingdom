struct NPCTile: Codable, Equatable {
	let type: NPCTileType

	init(type: NPCTileType) {
		self.type = type
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

	func talk() async {
		switch type {
			case .blacksmith:
				await BlacksmithNPC.talk()
			case .blacksmith_helper:
				BlacksmithHelperNPC.talk()
			case .miner:
				await MinerNPC.talk()
			case .mine_helper:
				MineHelperNPC.talk()
			case .carpenter:
				CarpenterNPC.talk()
			case .carpenter_helper:
				CarpenterHelperNPC.talk()
			case .king:
				KingNPC.talk()
			case .salesman:
				await SalesmanNPC.talk()
			case .builder:
				await BuilderNPC.talk()
			case .builder_helper:
				BuilderHelperNPC.talk()
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
				break
			case .farmer_helper:
				FarmerHelperNPC.talk()
		}
	}
}

extension NPCTile {
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(type, forKey: .tileType)
	}

	enum CodingKeys: CodingKey {
		case tileType
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.type = try container.decode(NPCTileType.self, forKey: .tileType)
	}
}
