import Foundation

struct Building: Codable, Equatable {
    let id: UUID
    let type: DoorTileTypes
    let isPartOfPlayerVillage: Bool
    private(set) var level: Int
    var insideMap: [[MapTile]]
    let buildingShape: [[MapTile]]

    init(id: UUID = UUID(), type: DoorTileTypes, isPartOfPlayerVillage: Bool, insideMap: [[MapTile]], buildingShape: [[MapTile]]) {
        self.id = id
        self.type = type
        self.isPartOfPlayerVillage = isPartOfPlayerVillage
        self.level = 1
        self.insideMap = insideMap
        self.buildingShape = buildingShape
    }
}
