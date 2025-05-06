enum LeadBlacksmithWork {
	static func work(npc: inout NPC) async {
		guard case let .lead_blacksmith(leadBlacksmithTasks) = npc.task else {
			return
		}
		switch leadBlacksmithTasks {
			case let .collectMaterials(items, from):
			case let .create(item):
			case .idle:
			case .moveTo:
			case let .smelt(item):
		}
		//! TODO: Implement LeadBlacksmithWork
	}
}

enum BlacksmithWork {
	static func work(npc: inout NPC) async {
		//! TODO: Implement BlacksmithWork
	}
}
