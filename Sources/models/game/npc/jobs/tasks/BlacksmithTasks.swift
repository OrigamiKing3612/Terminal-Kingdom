enum LeadBlacksmithTasks: Codable, Hashable {
	case idle
	case moveTo(TilePosition)
	case collectMaterials(items: [ItemAmount], from: NPCJob)
	case smelt(item: ItemType)
	case create(item: ItemType)
}

enum BlacksmithTasks: Codable, Hashable {
	case idle
	case moveTo(TilePosition)
	case collectMaterials(items: [ItemAmount], from: NPCJob)
	case smelt(item: ItemType)
	case create(item: ItemType)
}
