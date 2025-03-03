enum CollectCropEvent {
	static func collectCrop(cropTile: CropTile, isInPot: Bool) async {
		let mtile = await MapBox.tilePlayerIsOn
		if isInPot {
			if cropTile.type != .none {
				await cropTileToItem(cropTile.type)
				await MapBox.updateTile(newTile: .init(type: .pot(tile: .init(cropTile: .init(type: .none))), event: .collectCrop, biome: mtile.biome))
			} else {
				await MessageBox.message("There is no crop here", speaker: .game)
			}
		} else {
			if case let .crop(crop: tile) = await MapBox.tilePlayerIsOn.type {
				_ = await cropTileToItem(tile.type, count: Int.random(in: 1 ... 3))
				await MapBox.updateTile(newTile: .init(type: .plain, biome: mtile.biome))
			} else {
				await MessageBox.message("There is no crop here", speaker: .game)
			}
		}
	}

	private static func cropTileToItem(_ cropTileType: CropTileType, count: Int = 1) async {
		switch cropTileType {
			case .carrot:
				_ = await Game.shared.player.collect(item: .init(type: .carrot), count: count)
			case .potato:
				_ = await Game.shared.player.collect(item: .init(type: .potato), count: count)
			case .wheat:
				_ = await Game.shared.player.collect(item: .init(type: .wheat), count: count)
			case .lettuce:
				_ = await Game.shared.player.collect(item: .init(type: .lettuce), count: count)
			case .tree_seed:
				await MessageBox.message("Timber!", speaker: .game)
				let lumberCount = Int.random(in: 1 ... 3)
				let seedCount = Int.random(in: 0 ... 2)
				_ = await Game.shared.player.collect(item: .init(type: .lumber), count: lumberCount)
				_ = await Game.shared.player.collect(item: .init(type: .tree_seed), count: seedCount)
			case .none:
				break
		}
	}
}
