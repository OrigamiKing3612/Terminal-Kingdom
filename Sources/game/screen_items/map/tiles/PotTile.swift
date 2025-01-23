struct PotTile: Codable, Equatable {
	let cropTile: CropTile

	init(cropTile: CropTile = .init(type: .none)) {
		self.cropTile = cropTile
	}

	static func renderCropInPot(tile: PotTile) async -> String {
		if tile.cropTile.type == .none {
			await Game.shared.config.useNerdFont ? "󰋥" : "p"
		} else {
			await CropTile.renderCrop(tile: tile.cropTile)
		}
	}
}
