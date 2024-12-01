struct CropTile: Codable, Equatable {
    let type: CropTileType
    
    init(type: CropTileType) {
        self.type = type
    }
    
    static func renderCrop(tile: CropTile) -> String {
        switch tile.type {
            case .none:
                return "."
            case .carrot:
                return "c"
            case .potato:
                return "p"
            case .wheat:
                return "w"
            case .lettuce:
                return "l"
        }
    }
}
