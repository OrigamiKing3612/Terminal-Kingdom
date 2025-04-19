// TODO: Give starting village NPCs names?
enum NPCJob: Codable, Hashable, Equatable {
	case lead_blacksmith
	case blacksmith
	case lead_miner
	case miner
	case lead_carpenter
	case carpenter
	case lead_farmer
	case farmer
	case lead_builder
	case builder

	case king
	case salesman(type: SalesmanType)
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
			case .lead_blacksmith: "Lead Blacksmith"
			case .lead_miner: "Lead Miner"
			case .lead_carpenter: "Carpenter"
			case .lead_builder: "Builder"
			case .lead_farmer: "Farmer"
		}
	}

	var isLead: Bool {
		switch self {
			case .lead_blacksmith, .lead_miner, .lead_carpenter, .lead_builder, .lead_farmer: true
			default: false
		}
	}
}

enum MessageSpeakers: Equatable {
	case player
	case game
	case dev
	case npc(name: String, job: NPCJob?)

	var render: String {
		get async {
			switch self {
				case .player: await Game.shared.player.name
				case .game: "This shouldn't be seen"
				case .dev: "Dev"
				case let .npc(name: name, job: job):
					if let job {
						"\(name) (\(job.render))"
					} else {
						"\(name)"
					}
			}
		}
	}
}

enum SalesmanType: Codable {
	case buy, sell, help
}
