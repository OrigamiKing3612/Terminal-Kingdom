struct StationTile: Codable, Equatable {
	let tileType: StationTileType

	init(tileType: StationTileType) {
		self.tileType = tileType
	}

	static func render(tile: StationTile) -> String {
		tile.tileType.render
	}
}
