enum CollectCropEvent {
	static func collectCrop(cropTile: CropTile, isInPot: Bool) {
		if isInPot {
			if cropTile.tileType != .none {
				_ = Game.player.collect(item: .init(type: cropTileToItem(cropTile.tileType)!))
				MapBox.updateTile(newTile: .init(type: .pot(tile: .init(cropTile: .init(tileType: .none))), event: .collectCrop))
			} else {
				MessageBox.message("There is no crop here", speaker: .game)
			}
		} else {
			if case let .crop(crop: tile) = MapBox.tilePlayerIsOn.type {
				_ = Game.player.collect(item: .init(type: cropTileToItem(tile.tileType)!), count: Int.random(in: 1 ... 3))
				MapBox.updateTile(newTile: .init(type: .plain))
			} else {
				MessageBox.message("There is no crop here", speaker: .game)
			}
		}
	}

	private static func cropTileToItem(_ cropTileType: CropTileType) -> ItemType? {
		switch cropTileType {
			case .carrot:
				.carrot
			case .potato:
				.potato
			case .wheat:
				.wheat
			case .lettuce:
				.lettuce
			default:
				nil
		}
	}
}
