struct DoorTile: Codable, Equatable {
    let type: DoorTileTypes
    let isPartOfPlayerVillage: Bool
    private(set) var level: Int
    
    init(type: DoorTileTypes, isPartOfPlayerVillage: Bool = false) {
        self.type = type
        self.isPartOfPlayerVillage = isPartOfPlayerVillage
        self.level = 1
    }
    
    static func renderDoor(tile: DoorTile) -> String {
        if Game.stages.blacksmith.stage1Stages == .goToMine && tile.type == .mine {
            return "!".styled(with: [.bold, .red])
        }
        return "D".styled(with: .bold)
    }
}
