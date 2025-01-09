struct PotTile: Codable, Equatable {
	let cropTile: CropTile?

	init(cropTile: CropTile? = nil) {
		self.cropTile = cropTile
	}

	static func renderCropInPot(tile: PotTile) -> String {
		if let cropTile = tile.cropTile {
			CropTile.renderCrop(tile: cropTile)
		} else {
			"p"
		}
	}
}
