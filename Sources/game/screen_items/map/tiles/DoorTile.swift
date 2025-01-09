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
        let conditions: [(DoorTileTypes, Bool)] = [
            (.mine, Game.stages.blacksmith.stage1Stages == .goToMine),
            (.blacksmith, Game.stages.mine.stage1Stages == .collect),
            (.shop, Game.stages.mine.stage10Stages == .goToSalesman),
            (.carpenter, Game.stages.blacksmith.stage3Stages == .goToCarpenter),
            (.hunting_area, Game.stages.blacksmith.stage7Stages == .bringToHunter),
            (.shop, Game.stages.blacksmith.stage9Stages == .goToSalesman)
        ]
        if MapBox.mapType == .mainMap {
            for (doorType, condition) in conditions {
                if tile.type == doorType && condition {
                    return "!".styled(with: [.bold, .red])
                }
            }
        }
        return "D".styled(with: .bold)
    }
}
