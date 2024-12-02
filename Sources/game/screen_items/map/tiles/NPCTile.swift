struct NPCTile: Codable, Equatable {
    let type: NPCTileType
    
    init(type: NPCTileType) {
        self.type = type
    }
    
    static func renderNPC(tile: NPCTile) -> String {
        switch tile.type {
            case .blacksmith where !Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith:
                return "!".styled(with: [.bold, .red])
            case .miner where !Game.startingVillageChecks.firstTimes.hasTalkedToMiner:
                return "!".styled(with: [.bold, .red])
            case .carpenter where !Game.startingVillageChecks.firstTimes.hasTalkedToCarpenter:
                return "!".styled(with: [.bold, .red])
            case .salesman where !Game.startingVillageChecks.firstTimes.hasTalkedToSalesman:
                return "!".styled(with: [.bold, .red])
            case .king where !Game.startingVillageChecks.firstTimes.hasTalkedToKing:
                return "!".styled(with: [.bold, .red])
            case .builder where !Game.startingVillageChecks.firstTimes.hasTalkedToBuilder:
                return "!".styled(with: [.bold, .red])
            case .hunter where !Game.startingVillageChecks.firstTimes.hasTalkedToHunter:
                return "!".styled(with: [.bold, .red])
            case .inventor where !Game.startingVillageChecks.firstTimes.hasTalkedToInventor:
                return "!".styled(with: [.bold, .red])
            case .stable_master where !Game.startingVillageChecks.firstTimes.hasTalkedToStableMaster:
                return "!".styled(with: [.bold, .red])
            case .farmer where !Game.startingVillageChecks.firstTimes.hasTalkedToFarmer:
                return "!".styled(with: [.bold, .red])
            case .doctor where !Game.startingVillageChecks.firstTimes.hasTalkedToDoctor:
                return "!".styled(with: [.bold, .red])
            case .chef where !Game.startingVillageChecks.firstTimes.hasTalkedToChef:
                return "!".styled(with: [.bold, .red])
            case .potter where !Game.startingVillageChecks.firstTimes.hasTalkedToPotter:
                return "!".styled(with: [.bold, .red])
            default:
                return "N".styled(with: .bold)
        }
    }
    
    func talk() {
        switch self.type {
            case .blacksmith:
                BlacksmithNPC.talk()
            case .blacksmith_helper:
                BlacksmithHelperNPC.talk()
            case .miner:
                MinerNPC.talk()
            case .mine_helper:
                break
            case .carpenter:
                CarpenterNPC.talk()
            case .carpenter_helper:
                CarpenterHelperNPC.talk()
            case .king:
                break
            case .salesman:
                SalesmanNPC.talk()
            case .builder:
                BuilderNPC.talk()
            case .builder_helper:
                BuilderHelperNPC.talk()
            case .hunter:
                break
            case .inventor:
                break
            case .stable_master:
                break
            case .farmer:
                FarmerNPC.talk()
            case .doctor:
                break
            case .chef:
                break
            case .potter:
                break
        }
    }
}
