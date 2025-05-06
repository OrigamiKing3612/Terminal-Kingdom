enum LeadMinerTasks: Codable, Hashable {
	case idle
	case moveTo(TilePosition)
	case collectMaterials(items: [ItemAmount], from: NPCJob)
	case mine
}

enum MinerTasks: Codable, Hashable {
	case idle
	case moveTo(TilePosition)
	case collectMaterials(items: [ItemAmount], from: NPCJob)
	case mine
}
