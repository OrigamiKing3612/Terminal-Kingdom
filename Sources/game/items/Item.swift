enum Item: Codable, Equatable {
    //MARK: Weapons
    case sword, axe, pickaxe(durability: Int = 50), boomerang  // bow? net? dagger?
    
    //MARK: Armor?
    case backpack(type: BackpackType) // TODO: DO BACKPACK
    
    //MARK: Food
    
    //MARK: Materials
    case lumber //plank?
    case iron
    case coal
    case gold
    case stone
    case tree_seed
    
    //MARK: Buildings
    case door(tile: DoorTile)
    case fence
    case gate
    
    //MARK: Other
    case coin
    
    var inventoryName: String {
        switch self {
            case .sword: return "Sword"
            case .axe: return "Axe"
            case .pickaxe(let durability): return "Pickaxe (\(durability.description))"
            case .boomerang: return "Boomerang"
            case .backpack(type: let type): return "\(type.inventoryName) Backpack"
            case .lumber: return "Lumber"
            case .iron: return "Iron"
            case .coal: return "Coal"
            case .gold: return "Gold"
            case .stone: return "Stone"
            case .tree_seed: return "Tree Seed"
            case .door(tile: let tile): return "\(tile.type.name) Door"
            case .fence: return "Fence"
            case .gate: return "Gate"
            case .coin: return "Coin"
        }
    }
}

enum BackpackType: Codable, Equatable {
    case small, medium, large
    
    var inventoryName: String {
        switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
        }
    }
}
