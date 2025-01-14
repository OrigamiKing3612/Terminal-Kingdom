struct PotTile: Codable, Equatable {
	let cropTile: CropTile

	init(cropTile: CropTile = .init(tileType: .none)) {
		self.cropTile = cropTile
	}

	static func renderCropInPot(tile: PotTile) -> String {
		if tile.cropTile.tileType == .none {
			Game.config.useNerdFont ? "󰋥" : "p"
		} else {
			CropTile.renderCrop(tile: tile.cropTile)
		}
	}
}
