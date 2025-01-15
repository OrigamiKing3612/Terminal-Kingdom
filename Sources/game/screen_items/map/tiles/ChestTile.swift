struct ChestTile: Codable, Equatable, Hashable {
	let items: [Item]
	let isPlacedByPlayer: Bool

	init(items: [Item] = [], isPlacedByPlayer: Bool = false) {
		self.items = items
		self.isPlacedByPlayer = isPlacedByPlayer
	}
}
