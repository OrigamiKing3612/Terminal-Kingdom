struct MapTile: Tile {
    let type: MapTileType
    let isWalkable: Bool
    let event: MapTileEvent?
    
    init(type: MapTileType, isWalkable: Bool = true, event: MapTileEvent? = nil) {
        self.type = type
        self.isWalkable = isWalkable
        self.event = event
    }
    
    var isInteractable: Bool {
        event != nil
    }
    
    static func == (lhs: MapTile, rhs: MapTile) -> Bool {
        lhs.type == rhs.type
    }
    
    static func findTilePosition(of type: MapTileType, in grid: [[MapTile]]) -> (Int, Int)? {
        for (y, row) in grid.enumerated() {
            if let x = row.firstIndex(where: { $0.type == type }) {
                return (x, y)
            }
        }
        return nil // Return nil if the tile is not found
    }
}

protocol Tile: Equatable, Codable {
    associatedtype pTileType: TileType
    associatedtype pTileEvent: TileEvent
    
    var type: pTileType { get }
    var isWalkable: Bool { get }
    var event: pTileEvent? { get }
}

protocol TileType: Equatable, Codable {
//    func render() -> String
    var name: String { get }
}

protocol TileEvent: Equatable, Codable {
    var name: String { get }
}
