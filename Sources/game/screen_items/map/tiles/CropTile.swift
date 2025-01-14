struct CropTile: Codable, Equatable {
	let tileType: CropTileType

	init(tileType: CropTileType) {
		self.tileType = tileType
	}

	static func renderCrop(tile: CropTile) -> String {
		switch tile.tileType {
			case .none:
				"."
			case .tree_seed:
				Game.config.useNerdFont ? "" : "t"
			case .carrot:
				Game.config.useNerdFont ? "" : "c"
			case .potato:
				"p"
			case .wheat:
				"w"
			case .lettuce:
				"l"
		}
	}
}
