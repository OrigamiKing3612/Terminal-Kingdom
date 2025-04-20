enum LeadFarmerTasks: Codable, Hashable {
	case idle
	case moveTo(TilePosition)
	case plant
	case wait
	case harvest
	case collect
}

enum FarmerTasks: Codable, Hashable {
	case idle
	case moveTo(TilePosition)
	case plant
	case wait
	case harvest
	case collect
}
