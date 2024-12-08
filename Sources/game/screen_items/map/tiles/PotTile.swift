struct PotTile: Codable, Equatable {
    let cropTile: CropTile?
    
    init(cropTile: CropTile? = nil) {
        self.cropTile = cropTile
    }
    
    static func renderCropInPot(tile: PotTile) -> String {
        if let cropTile = tile.cropTile {
            return CropTile.renderCrop(tile: cropTile)
        } else {
            return "p"
        }
    }
}
