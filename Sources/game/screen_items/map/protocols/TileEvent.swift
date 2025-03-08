protocol TileEvent: Equatable, Hashable, Codable {
	var name: String { get async }
}
