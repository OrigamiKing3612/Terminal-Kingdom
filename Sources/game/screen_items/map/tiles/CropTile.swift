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

extension CropTile {
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(type, forKey: .tileType)
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.type = try container.decode(CropTileType.self, forKey: .tileType)
	}

	enum CodingKeys: CodingKey {
		case tileType
	}
}
