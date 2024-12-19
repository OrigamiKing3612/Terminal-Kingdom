import Foundation

struct BlacksmithStages: Codable {
    private(set) var stageNumber = 0
    var stage1AIronUUIDsToRemove: [UUID]?
    var stage2AxeUUIDToRemove: UUID?
    var stage3LumberUUIDsToRemove: [UUID]?
    var stage4CoalUUIDsToRemove: [UUID]?
    var stage5ItemsToMakeSteelUUIDs: [UUID]?
    var stage5SteelUUIDsToRemove: [UUID]?
    var stage6ItemsToMakePickaxeUUIDs: [UUID]?
    var stage6PickaxeUUIDToRemove: UUID?
    var stage7ItemsToMakeSwordUUIDs: [UUID]?
    var stage7SwordUUIDToRemove: UUID?
    var stage8MaterialsToRemove: [UUID]?
    var stage9SteelUUIDToRemove: [UUID]?

    var stage1Stages: BlacksmithStage1Stages = .notStarted
    var stage2Stages: BlacksmithStage2Stages = .notStarted
    var stage3Stages: BlacksmithStage3Stages = .notStarted
    var stage4Stages: BlacksmithStage4Stages = .notStarted
    var stage5Stages: BlacksmithStage5Stages = .notStarted
    var stage6Stages: BlacksmithStage6Stages = .notStarted
    var stage7Stages: BlacksmithStage7Stages = .notStarted
    var stage8Stages: BlacksmithStage8Stages = .notStarted
    var stage9Stages: BlacksmithStage9Stages = .notStarted

    mutating func next() {
        stageNumber += 1
    }
}
