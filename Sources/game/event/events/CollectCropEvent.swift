enum CollectCropEvent {
	static func collectCrop(cropTile: CropTile, isInPot: Bool) async {
		let mtile = await MapBox.tilePlayerIsOn
		if isInPot {
			if cropTile.type != .none {
				_ = await Game.shared.player.collect(item: .init(type: cropTileToItem(cropTile.type)!))
				await MapBox.updateTile(newTile: .init(type: .pot(tile: .init(cropTile: .init(type: .none))), event: .collectCrop, biome: mtile.biome))
			} else {
				await MessageBox.message("There is no crop here", speaker: .game)
			}
		} else {
			if case let .crop(crop: tile) = await MapBox.tilePlayerIsOn.type {
				_ = await Game.shared.player.collect(item: .init(type: cropTileToItem(tile.type)!), count: Int.random(in: 1 ... 3))
				await MapBox.updateTile(newTile: .init(type: .plain, biome: mtile.biome))
			} else {
				await MessageBox.message("There is no crop here", speaker: .game)
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
