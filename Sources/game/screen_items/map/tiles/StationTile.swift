struct StationTile: Codable, Equatable {
	let type: StationTileType

	init(type: StationTileType) {
		self.type = type
	}

	static func render(tile: StationTile) -> String {
		tile.type.render
	}
}
