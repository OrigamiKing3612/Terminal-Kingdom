struct NPCTile: Codable, Equatable {
    let type: NPCTileType

    init(type: NPCTileType) {
        self.type = type
    }

    static func renderNPC(tile: NPCTile) -> String {
        if !tile.type.hasTalkedToBefore {
            return "!".styled(with: [.bold, .red])
        }
        switch tile.type {
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
                MineHelperNPC.talk()
            case .carpenter:
                CarpenterNPC.talk()
            case .carpenter_helper:
                CarpenterHelperNPC.talk()
            case .king:
                KingNPC.talk()
            case .salesman:
                SalesmanNPC.talk()
            case .builder:
                BuilderNPC.talk()
            case .builder_helper:
                BuilderHelperNPC.talk()
            case .hunter:
                HunterNPC.talk()
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
            case .farmer_helper:
                FarmerHelperNPC.talk()
        }
    }
}
