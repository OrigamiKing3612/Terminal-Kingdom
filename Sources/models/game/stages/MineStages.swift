import Foundation

struct MineStages: Codable {
	private(set) var stageNumber = 0
	var isDone: Bool { stageNumber > 10 }
	var stage1PickaxeUUIDToRemove: UUID?
	var stage2PickaxeUUIDToRemove: UUID?
	var stage3AxeUUIDToRemove: UUID?
	var stage4PickaxeUUIDToRemove: UUID?
	var stage5PickaxeUUIDToRemove: UUID?
	var stage6AxeUUIDToRemove: UUID?
	var stage7ItemUUIDsToRemove: [UUID]?
	var stage8PickaxeUUID: UUID?
	var stage9PickaxeUUIDToRemove: UUID?
	var stage10GoldUUIDsToRemove: [UUID]?

	var stage1Stages: MineStage1Stages = .notStarted
	var stage2Stages: MineStage2Stages = .notStarted
	var stage3Stages: MineStage3Stages = .notStarted
	var stage4Stages: MineStage4Stages = .notStarted {
		didSet {
			StatusBox.questBoxUpdate()
		}
	}

	var stage5Stages: MineStage5Stages = .notStarted
	var stage6Stages: MineStage6Stages = .notStarted {
		didSet {
			StatusBox.questBoxUpdate()
		}
	}

	var stage7Stages: MineStage7Stages = .notStarted
	var stage8Stages: MineStage8Stages = .notStarted
	var stage9Stages: MineStage9Stages = .notStarted
	var stage10Stages: MineStage10Stages = .notStarted {
		didSet {
			StatusBox.questBoxUpdate()
		}
	}

	mutating func next() {
		stageNumber += 1
	}
}
