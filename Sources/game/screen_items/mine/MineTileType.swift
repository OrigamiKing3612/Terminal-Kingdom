enum MineTileType: Equatable, Codable {
    //MARK: Plains Biome
    case plain
    case player
    case playerStart
    case stone
    case coal
    case iron
    
    func render(tile: MineTile, tileX: Int, tileY: Int) -> String {
        let name = switch self {
            case .plain: " "
            case .player: "*".styled(with: [.blue, .bold])
            case .playerStart: " "
            case .stone: !MineTile.isSeen(tile: tile, tileX: tileX, tileY: tileY) ? "." : "S"
            case .coal: !MineTile.isSeen(tile: tile, tileX: tileX, tileY: tileY) ? "." : "C".styled(with: .dim)
            case .iron: !MineTile.isSeen(tile: tile, tileX: tileX, tileY: tileY) ? "." : "I".styled(with: .bold)
        }
        return name
    }
}
