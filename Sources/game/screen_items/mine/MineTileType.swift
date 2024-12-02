enum MineTileType: Equatable, Codable {
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
}
