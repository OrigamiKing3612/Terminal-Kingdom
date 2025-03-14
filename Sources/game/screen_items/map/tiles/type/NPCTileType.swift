enum NPCTileType: Codable, Hashable, Equatable {
	case blacksmith
	case blacksmith_helper
	case miner
	case mine_helper
	case carpenter
	case carpenter_helper
	case farmer
	case farmer_helper
	case citizen(type: CitizenType)

	case king
	case salesman(type: SalesmanType)
	case builder
	case builder_helper
	case hunter
	case inventor
	case stable_master
	case doctor
	case chef
	case potter

	var render: String {
		switch self {
			case .king: "King Randolph"
			case .blacksmith: "Blacksmith"
			case .miner: "Miner"
			case .salesman(type: _): "Salesman"
			case .builder: "Builder"
			case .hunter: "Hunter"
			case .inventor: "Inventor"
			case .stable_master: "Stable Master"
			case .farmer: "Farmer"
			case .doctor: "Doctor"
			case .carpenter: "Carpenter"
			case .chef: "Chef"
			case .potter: "Potter"
			case .blacksmith_helper: "Blacksmith Helper"
			case .mine_helper: "Miner Helper"
			case .carpenter_helper: "Carpenter Helper"
			case .builder_helper: "Builder Helper"
			case .farmer_helper: "Farmer Helper"
			case let .citizen(type): type.name
		}
	}

	var queueName: String {
		"\(render.lowercased().replacingOccurrences(of: " ", with: "_"))"
	}

	var hasTalkedToBefore: Bool {
		get async {
			switch self {
				case .blacksmith:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToBlacksmith
				case .blacksmith_helper:
					true
				case .builder:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToBuilder
				case .builder_helper:
					true
				case .carpenter:
					true
				case .carpenter_helper:
					true
				case .chef:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToChef
				case .doctor:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToDoctor
				case .farmer:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToFarmer
				case .farmer_helper:
					true
				case .hunter:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToHunter
				case .inventor:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToInventor
				case .king:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToKing
				case .mine_helper:
					true
				case .miner:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToMiner
				case .potter:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToPotter
				case let .salesman(type):
					switch type {
						case .help:
							await Game.shared.startingVillageChecks.firstTimes.hasTalkedToSalesmanHelp
						case .buy:
							await Game.shared.startingVillageChecks.firstTimes.hasTalkedToSalesmanBuy
						case .sell:
							await Game.shared.startingVillageChecks.firstTimes.hasTalkedToSalesmanSell
					}
				case .stable_master:
					await Game.shared.startingVillageChecks.firstTimes.hasTalkedToStableMaster
				case .citizen:
					true
			}
		}
	}
}

enum MessageSpeakers {
	case player
	case game
	case dev

	var render: String {
		get async {
			switch self {
				case .player: await Game.shared.player.name
				case .game: "This shouldn't be seen"
				case .dev: "Dev"
			}
		}
	}
}

enum SalesmanType: Codable {
	case buy, sell, help
}
