struct NPCTile: Codable, Equatable {
    let type: NPCTileType
    
    init(type: NPCTileType) {
        self.type = type
    }
    
    static func renderNPC(tile: NPCTile) -> String {
        return "N".styled(with: .bold)
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
                break
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
