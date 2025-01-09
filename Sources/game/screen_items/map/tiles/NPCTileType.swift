enum NPCTileType: Codable, Equatable {
	case blacksmith
	case blacksmith_helper
	case miner
	case mine_helper
	case carpenter
	case carpenter_helper
	case farmer
	case farmer_helper

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
		}
	}

	var hasTalkedToBefore: Bool {
		switch self {
			case .blacksmith:
				Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith
			case .blacksmith_helper:
				true
			case .builder:
				Game.startingVillageChecks.firstTimes.hasTalkedToBuilder
			case .builder_helper:
				true
			case .carpenter:
				Game.startingVillageChecks.firstTimes.hasTalkedToCarpenter
			case .carpenter_helper:
				true
			case .chef:
				Game.startingVillageChecks.firstTimes.hasTalkedToChef
			case .doctor:
				Game.startingVillageChecks.firstTimes.hasTalkedToDoctor
			case .farmer:
				Game.startingVillageChecks.firstTimes.hasTalkedToFarmer
			case .farmer_helper:
				true
			case .hunter:
				Game.startingVillageChecks.firstTimes.hasTalkedToHunter
			case .inventor:
				Game.startingVillageChecks.firstTimes.hasTalkedToInventor
			case .king:
				Game.startingVillageChecks.firstTimes.hasTalkedToKing
			case .mine_helper:
				true
			case .miner:
				Game.startingVillageChecks.firstTimes.hasTalkedToMiner
			case .potter:
				Game.startingVillageChecks.firstTimes.hasTalkedToPotter
			case let .salesman(type):
				switch type {
					case .help:
						Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanHelp
					case .buy:
						Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanBuy
					case .sell:
						Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanSell
				}
			case .stable_master:
				Game.startingVillageChecks.firstTimes.hasTalkedToStableMaster
		}
	}
}

enum MessageSpeakers {
	case player // TODO: do I need this
	case game
	case dev

	var render: String {
		switch self {
			case .player: Game.player.name
			case .game: "This shouldn't be seen"
			case .dev: "Dev"
		}
	}
}

enum SalesmanType: Codable {
	case buy, sell, help
}
