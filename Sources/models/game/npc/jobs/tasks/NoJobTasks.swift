enum NoJobTasks: Codable, Hashable {
	case idle
	case moveTo(TilePosition)
}
