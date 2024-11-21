struct Tile: Equatable, Codable {
    let type: TileType
    let isWalkable: Bool
    var event: TileEvent?
    
    init(type: TileType, isWalkable: Bool = true, event: TileEvent? = nil) {
        self.type = type
        self.isWalkable = isWalkable
        self.event = event
    }
    
    var isInteractable: Bool {
        event != nil
    }
    
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        lhs.type == rhs.type
    }
    
    static func findTilePosition(of type: TileType, in grid: [[Tile]]) -> (Int, Int)? {
        for (y, row) in grid.enumerated() {
            if let x = row.firstIndex(where: { $0.type == type }) {
                return (x, y)
            }
        }
        return nil // Return nil if the tile is not found
    }
}
