enum DoorTileTypes: Codable, Equatable {
    case castle
    case blacksmith
    case mine
    case shop
    case builder
    case hunting_area
    case inventor
    case house
    case stable
    case farm
    case hospital
    case carpenter
    case restaurant
    case potter
    
    var name: String {
        switch self {
            case .castle:
                return "Castle"
            case .blacksmith:
                return "Blacksmith"
            case .mine:
                return "Mine"
            case .shop:
                return "Shop"
            case .builder:
                return "Builder"
            case .hunting_area:
                return "Hunting Area"
            case .inventor:
                return "Inventor"
            case .house:
                return "House"
            case .stable:
                return "Stable"
            case .farm:
                return "Farm"
            case .hospital:
                return "Hospital"
            case .carpenter:
                return "Carpenter"
            case .restaurant:
                return "Restaurant"
            case .potter:
                return "Potter"
        }
    }
}
