struct MineTile: Equatable, Codable {
    let type: MineTileType
    var isWalkable: Bool
    var event: MineTileEvent?
    
    init(type: MineTileType, isWalkable: Bool = false, event: MineTileEvent? = nil) {
        self.type = type
        self.isWalkable = isWalkable
        self.event = event
    }
    
    var isInteractable: Bool {
        event != nil
    }
    
    static func isSeen(tile: MineTile, tileX: Int, tileY: Int) -> Bool {
        guard tile.type != .plain else { return true }
        
        let grid = MapBox.mineMap.grid
        let width = grid[0].count
        let height = grid.count
        
        if tileY + 1 < height, grid[tileY + 1][tileX].type == .plain {
            return true
        } else if tileY - 1 >= 0, grid[tileY - 1][tileX].type == .plain {
            return true
        } else if tileX + 1 < width, grid[tileY][tileX + 1].type == .plain {
            return true
        } else if tileX - 1 >= 0, grid[tileY][tileX - 1].type == .plain {
            return true
        }
        
        return false
    }
    
    static func == (lhs: MineTile, rhs: MineTile) -> Bool {
        lhs.type == rhs.type
    }
    
    static func findTilePosition(of type: MineTileType, in grid: [[MineTile]]) -> (Int, Int)? {
        for (y, row) in grid.enumerated() {
            if let x = row.firstIndex(where: { $0.type == type }) {
                return (x, y)
            }
        }
        return nil // Return nil if the tile is not found
    }
}
