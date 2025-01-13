struct BuildingTile: Codable, Equatable {
	let isPlacedByPlayer: Bool

	init(isPlacedByPlayer: Bool = false) {
		self.isPlacedByPlayer = isPlacedByPlayer
	}
}
