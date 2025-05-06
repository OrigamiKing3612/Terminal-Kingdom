enum NPCTasks: Codable, Hashable {
	case nojob(NoJobTasks)
	case lead_blacksmith(LeadBlacksmithTasks)
	case blacksmith(BlacksmithTasks)
	case lead_farmer(LeadFarmerTasks)
	case farmer(FarmerTasks)
	case lead_miner(LeadMinerTasks)
	case miner(MinerTasks)
	case lead_builder(LeadBuilderTasks)
	case builder(BuilderTasks)
}

extension NPCTasks {
	static func idle(for job: NPCJob?) -> NPCTasks {
		guard let job else { return .nojob(.idle) }
		return switch job {
			case .miner:
				.miner(.idle)
			case .blacksmith:
				.blacksmith(.idle)
			case .farmer:
				.farmer(.idle)
			case .builder:
				.builder(.idle)
			case .lead_blacksmith:
				.lead_blacksmith(.idle)
			case .lead_builder:
				.lead_builder(.idle)
			case .lead_farmer:
				.lead_farmer(.idle)
			case .lead_miner:
				.lead_miner(.idle)
			//! TODO: Add other jobs
			case .carpenter:
				.miner(.idle)
			case .chef:
				.miner(.idle)
			case .doctor:
				.miner(.idle)
			case .hunter:
				.miner(.idle)
			case .inventor:
				.miner(.idle)
			case .king:
				.miner(.idle)
			case .lead_carpenter:
				.miner(.idle)
			case .potter:
				.miner(.idle)
			case .salesman:
				.miner(.idle)
			case .stable_master:
				.miner(.idle)
		}
	}
}
