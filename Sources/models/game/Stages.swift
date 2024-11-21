struct Stages: Codable {
    //MARK: Blacksmith
    var blacksmith: BlacksmithStages = .init()
    var mine: MineStages = .init()
}

struct BlacksmithStages: Codable {
    var stageNumber = 0
    var stage: DoorStages = .no
    var stage1Stages: BlacksmithStage1Stages = .notStarted
}

struct MineStages: Codable {
    var stageNumber = 0
    var stage1Stages: MineStage1Stages = .notStarted
}

struct FarmStages: Codable {
    var stageNumber = 0
    var stage1Stages: FarmStage1Stages = .notStarted
}
