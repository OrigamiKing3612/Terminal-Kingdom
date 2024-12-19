enum NPCTileType: Codable, Equatable {
    case blacksmith
    case blacksmith_helper
    case miner
    case mine_helper
    case carpenter
    case carpenter_helper
    case farmer
    case farmer_helper
    
    case king
    case salesman(type: SalesmanType)
    case builder
    case builder_helper
    case hunter
    case inventor
    case stable_master
    case doctor
    case chef
    case potter
    
    var render: String {
        switch self {
            case .king: return "King Randolph"
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
            case .farmer_helper: return "Farmer Helper"
        }
    }
    var hasTalkedToBefore: Bool {
        switch self {
            case .blacksmith:
                return Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith
            case .blacksmith_helper:
                return true
            case .builder:
                return Game.startingVillageChecks.firstTimes.hasTalkedToBuilder
            case .builder_helper:
                return true
            case .carpenter:
                return Game.startingVillageChecks.firstTimes.hasTalkedToCarpenter
            case .carpenter_helper:
                return true
            case .chef:
                return Game.startingVillageChecks.firstTimes.hasTalkedToChef
            case .doctor:
                return Game.startingVillageChecks.firstTimes.hasTalkedToDoctor
            case .farmer:
                return Game.startingVillageChecks.firstTimes.hasTalkedToFarmer
            case .farmer_helper:
                return true
            case .hunter:
                return Game.startingVillageChecks.firstTimes.hasTalkedToHunter
            case .inventor:
                return Game.startingVillageChecks.firstTimes.hasTalkedToInventor
            case .king:
                return Game.startingVillageChecks.firstTimes.hasTalkedToKing
            case .mine_helper:
                return true
            case .miner:
                return Game.startingVillageChecks.firstTimes.hasTalkedToMiner
            case .potter:
                return Game.startingVillageChecks.firstTimes.hasTalkedToPotter
            case .salesman(let type):
                switch type {
                    case .help:
                        return Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanHelp
                    case .buy:
                        return Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanBuy
                    case .sell:
                        return Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanSell
                }
            case .stable_master:
                return Game.startingVillageChecks.firstTimes.hasTalkedToStableMaster
        }
    }
}
enum MessageSpeakers {
    case player //TODO: do I need this
    case game
    case dev
    
    var render: String {
        switch self {
            case .player: return Game.player.name
            case .game: return "This shouldn't be seen"
            case .dev: return "Dev"
        }
    }
}

enum SalesmanType: Codable {
    case buy, sell, help
}
