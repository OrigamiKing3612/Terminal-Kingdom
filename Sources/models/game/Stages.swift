import Foundation

struct Stages: Codable {
    //MARK: Blacksmith
    var random: RandomStages = .init()
    var blacksmith: BlacksmithStages = .init()
    var mine: MineStages = .init()
}

struct RandomStages: Codable {
    var chopTreeAxeUUIDToRemove: UUID?
}

struct BlacksmithStages: Codable {
    private(set) var stageNumber = 0
    var stage: DoorStages = .no
    var stage1AIronUUIDToRemove: UUID?
    var stage1Stages: BlacksmithStage1Stages = .notStarted

    mutating func next() {
        stageNumber += 1
    }
}

struct MineStages: Codable {
    private(set) var stageNumber = 0
    var stage1PickaxeUUIDToRemove: UUID?
    var stage2PickaxeUUIDToRemove: UUID?
    var stage3AxeUUIDToRemove: UUID?
    var stage4PickaxeUUIDToRemove: UUID?
    var stage1Stages: MineStage1Stages = .notStarted
    var stage2Stages: MineStage2Stages = .notStarted
    var stage3Stages: MineStage3Stages = .notStarted
    var stage4Stages: MineStage4Stages = .notStarted {
        didSet {
            StatusBox.statusBox()
        }
    }

    mutating func next() {
        stageNumber += 1
    }
}

struct FarmStages: Codable {
    private(set) var stageNumber = 0
    var stage1Stages: FarmStage1Stages = .notStarted

    mutating func next() {
        stageNumber += 1
    }
}
