enum TileType: Equatable, Codable {
    //MARK: Plains Biome
    case plain
    case water
    case tree

    //MARK: Desert Biome
    case sand
    case cactus

    //MARK: Snow Biome
    case snow
    case snow_tree
    case ice //TODO: slips and skips to another tile!
    
    //MARK: Other
    case path
    case building
    case player
    case door(tile: DoorTile)

    //MARK: Dont Generate
    case TOBEGENERATED
    case playerStart
    
    //MARK: Building Stuff
    case anvil
    case furnace
    case startMining
    
    //MARK: Crops
    case fence
    case gate
    case crop(crop: CropTile)
    
    //MARK: NPC
    case npc(tile: NPCTile)
    case shopStandingArea(type: ShopStandingAreaType)
    
    var render: String {
        return switch self {
            case .plain: " "
            case .water: "W".styled(with: .brightBlue)
            case .path: "P"
            case .tree: "󰐅".styled(with: .green)
            case .building: "#" //TODO: style dim if walkable
            case .player: "*".styled(with: [.blue, .bold])
            case .sand: "S".styled(with: .yellow)
            case .door(let doorTile): DoorTile.renderDoor(tile: doorTile)
            case .TOBEGENERATED: "."
            case .playerStart: " "
            case .snow: "S".styled(with: .bold)
            case .snow_tree: "󰐅".styled(with: .bold)
            case .cactus: "C".styled(with: .brightGreen)
            case .ice: "I".styled(with: .brightCyan)
            case .fence: "f".styled(with: .brown)
            case .gate: "g"
            case .crop(crop: let cropTile): CropTile.renderCrop(tile: cropTile)
            case .anvil: "a"
            case .furnace: "F"
            case .startMining: "M"
            case .npc(tile: let tile): NPCTile.renderNPC(tile: tile)
            case .shopStandingArea(type: _): "."
        }
    }
    
//    func specialAction(direction: Direction) -> () -> Void {
//        switch self {
//            case .ice:
//                return { movePlayer +1 direction }
//            default:
//                return {}
//        }
//    }
}

enum ShopStandingAreaType: Codable{
    case buy, sell, help
}
