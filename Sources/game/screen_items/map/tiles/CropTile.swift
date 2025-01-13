struct CropTile: Codable, Equatable {
	let type: CropTileType

	init(type: CropTileType) {
		self.type = type
	}

	static func renderCrop(tile: CropTile) -> String {
		switch tile.type {
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
