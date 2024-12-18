struct DoorTile: Codable, Equatable, Hashable {
    let type: DoorTileTypes
    let isPartOfPlayerVillage: Bool
    private(set) var level: Int

    init(type: DoorTileTypes, isPartOfPlayerVillage: Bool = false) {
        self.type = type
        self.isPartOfPlayerVillage = isPartOfPlayerVillage
        self.level = 1
    }

    static func renderDoor(tile: DoorTile) -> String {
        if MapBox.mapType == .mainMap {
            if Game.stages.blacksmith.stage1Stages == .goToMine && tile.type == .mine {
                return "!".styled(with: [.bold, .red])
            } else if Game.stages.mine.stage1Stages == .collect && tile.type == .blacksmith {
                return "!".styled(with: [.bold, .red])
            } else if Game.stages.mine.stage10Stages == .goToSalesman && tile.type == .shop {
                return "!".styled(with: [.bold, .red])
            }
        }
        return "D".styled(with: .bold)
    }
}
