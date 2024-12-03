enum NPCTileType: Codable, Equatable {
    case blacksmith
    case blacksmith_helper
    case miner
    case mine_helper
    case carpenter
    case carpenter_helper
    
    
    case king
    case salesman(type: SalesmanType)
    case builder
    case builder_helper
    case hunter
    case inventor
    case stable_master
    case farmer
    case doctor
    case chef
    case potter
    
    var render: String {
        switch self {
            case .king: return "King"
            case .blacksmith: return "Blacksmith"
            case .miner: return "Miner"
            case .salesman(type: _): return "Salesman"
            case .builder: return "Builder"
            case .hunter: return "Hunter"
            case .inventor: return "Inventor"
            case .stable_master: return "Stable Master"
            case .farmer: return "Farmer"
            case .doctor: return "Doctor"
            case .carpenter: return "Carpenter"
            case .chef: return "Chef"
            case .potter: return "Potter"
                
            case .blacksmith_helper: return "Blacksmith Helper"
            case .mine_helper: return "Miner Helper"
            case .carpenter_helper: return "Carpenter Helper"
            case .builder_helper: return "Builder Helper"
        }
    }
}
enum MessageSpeakers {
    case player //TODO: do I need this
    case game
    
    var render: String {
        switch self {
            case .player: return Game.player.name
            case .game: return "This shouldn't be seen"
        }
    }
}

enum SalesmanType: Codable {
    case buy, sell, help
}
