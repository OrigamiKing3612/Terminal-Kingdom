enum LeadBuilderTasks: Codable, Hashable {
	case idle
	case moveTo(TilePosition)
	// case build(BuildingType, TilePosition)
	case repair(TilePosition)
}

enum BuilderTasks: Codable, Hashable {
	case idle
	case moveTo(TilePosition)
	//! TODO: Implement the rest of the tasks
}
