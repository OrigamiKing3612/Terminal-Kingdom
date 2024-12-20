enum ItemType: Codable, Equatable, Hashable {
    //MARK: Weapons
    case sword, axe(type: AxeItem), pickaxe(type: PickaxeItem), boomerang  // bow? net? dagger?

    //MARK: Armor?
    case backpack(type: BackpackItem) // TODO: DO BACKPACK

    //MARK: Food

    //MARK: Materials
    case lumber //plank?
    case iron
    case coal
    case gold
    case stone
    case clay
    case tree_seed
    case stick
    case steel

    //MARK: Buildings
    case door(tile: DoorTile)
    case fence
    case gate

    //MARK: Other
    case coin

    var inventoryName: String {
        switch self {
            case .sword: return "Sword"
            case .axe(type: let type): return "Axe (\(type.durability))"
            case .pickaxe(type: let type): return "Pickaxe (\(type.durability))"
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
            case .clay: return "Clay"
            case .stick: return "Stick"
            case .steel: return "Steel"
        }
    }
    var price: Int? {
        switch self {
            case .sword: return 10
            case .axe(let type): return (type.durability / 11) * 2
            case .pickaxe(let type): return (type.durability / 10) * 2
            case .boomerang: return 10
            case .backpack(_): return 10
            case .lumber: return 1
            case .iron: return 5
            case .coal: return 2
            case .stone: return 5
            case .tree_seed: return 1
            case .clay: return 2
            case .stick: return 1
            case .steel: return 3
            default: return nil
        }
    }
}

enum BackpackItem: Codable, Equatable {
    case small, medium, large

    var inventoryName: String {
        switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
        }
    }
}
