enum MapTileType: TileType {
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
    case biomeTOBEGENERATED(type: BiomeType)
    
    //MARK: Building Stuff
    case anvil
    case furnace
    case startMining
    
    //MARK: Crops
    case fence
    case gate
    //TODO: rename crop -> tile
    case crop(crop: CropTile)
    case pot(tile: PotTile)
    
    //MARK: NPC
    case npc(tile: NPCTile)
    case shopStandingArea(type: ShopStandingAreaType)
    
    func render() -> String {
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
            case .pot(tile: let potTile): PotTile.renderCropInPot(tile: potTile)
            case .anvil: "a"
            case .furnace: "F"
            case .startMining: "M"
            case .npc(tile: let tile): NPCTile.renderNPC(tile: tile)
            case .shopStandingArea(type: _): "."
            case .biomeTOBEGENERATED(type: _): "/"
        }
    }
    
    var name: String {
        switch self {
            case .plain: return "plain"
            case .water: return "water"
            case .tree: return "tree"
            case .sand: return "sand"
            case .cactus: return "cactus"
            case .snow: return "snow"
            case .snow_tree: return "snow_tree"
            case .ice: return "ice"
            case .path: return "path"
            case .building: return "building"
            case .player: return "player"
            case .door(let tile): return tile.type.name
            case .TOBEGENERATED: return "TOBEGENERATED"
            case .playerStart: return "playerStart"
            case .anvil: return "anvil"
            case .furnace: return "furnace"
            case .startMining: return "startMining"
            case .fence: return "fence"
            case .gate: return "gate"
            case .crop(let crop):
                return crop.type.rawValue
            case .pot(let tile):
                return tile.cropTile?.type.rawValue ?? "nil"
            case .npc(let tile):
                return tile.type.render
            case .shopStandingArea(let type):
                return type.rawValue
            case .biomeTOBEGENERATED(type: let biome):
                return biome.rawValue
        }
    }
    
    func specialAction(direction: Direction, player: inout Player, grid: [[MapTile]]) {
        func isWalkable(x: Int, y: Int) -> Bool {
            guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
            return grid[y][x].isWalkable
        }
        switch self {
            case .ice:
                switch direction {
                    case .up where isWalkable(x: player.x, y: player.y - 1):
                        player.y -= 1
                    case .down where isWalkable(x: player.x, y: player.y + 1):
                        player.y += 1
                    case .left where isWalkable(x: player.x - 1, y: player.y):
                        player.x -= 1
                    case .right where isWalkable(x: player.x + 1, y: player.y):
                        player.x += 1
                    default:
                        break
                }
            default:
                return
        }
    }
}

enum ShopStandingAreaType: String, Codable {
    case buy, sell, help
}

enum BiomeType: String, Codable {
    case plains, desert, snow, forest
}
