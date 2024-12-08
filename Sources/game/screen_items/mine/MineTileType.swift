enum MineTileType: TileType {
    //MARK: Plains Biome
    case plain
    case player
    case playerStart
    case stone
    case coal
    case iron
    
    func render(grid: [[MineTile]], tileX: Int, tileY: Int) -> String {
        let tile = grid[tileY][tileX]
        let name = switch self {
            case .plain: " "
            case .player: "*".styled(with: [.blue, .bold])
            case .playerStart: " "
            case .stone: !MineTile.isSeen(tile: tile, tileX: tileX, tileY: tileY, grid: grid) ? "." : "S"
            case .coal: !MineTile.isSeen(tile: tile, tileX: tileX, tileY: tileY, grid: grid) ? "." : "C".styled(with: .dim)
            case .iron: !MineTile.isSeen(tile: tile, tileX: tileX, tileY: tileY, grid: grid) ? "." : "I".styled(with: .bold)
        }
        return name
    }
    var name: String {
        switch self {
            case .plain: return "plain"
            case .player: return "player"
            case .playerStart: return "playerStart"
            case .stone: return "stone"
            case .coal: return "coal"
            case .iron: return "iron"
        }
    }
}
