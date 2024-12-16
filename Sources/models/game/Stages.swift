struct Stages: Codable {
    //MARK: Blacksmith
    var blacksmith: BlacksmithStages = .init()
    var mine: MineStages = .init()
}

struct BlacksmithStages: Codable {
    private(set) var stageNumber = 0
    var stage: DoorStages = .no
    var stage1Stages: BlacksmithStage1Stages = .notStarted

    mutating func next() {
        stageNumber += 1
    }
}

struct MineStages: Codable {
    private(set) var stageNumber = 0
    var stage1Stages: MineStage1Stages = .notStarted
    var stage2Stages: MineStage2Stages = .notStarted
    var stage3Stages: MineStage3Stages = .notStarted

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
