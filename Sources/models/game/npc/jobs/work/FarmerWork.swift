enum LeadFarmerWork {
	static func work(npc: inout NPC) async {
		//! TODO: Implement LeadFarmerWork
	}
}

enum FarmerWork {
	static func work(npc: inout NPC) async {
		guard case let .farmer(farmerTasks) = npc.task else {
			Logger.error("NPC's task doesn't match its job", code: .taskMismatch)
		}
		//! TODO: Implement FarmerWork
		// switch farmerTasks {
		// 	case .idle:
		// 	case .moveTo:
		// 	case .plant:
		// 	case .wait:
		// 	case .harvest:
		// if canHarest {}
		// }
	}
}
