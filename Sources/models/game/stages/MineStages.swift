import Foundation

struct MineStages: Codable {
	private(set) var stageNumber = 0
	nonisolated(unsafe) var isDone: Bool { stageNumber > 10 }
	nonisolated(unsafe) var stage1PickaxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage2PickaxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage3AxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage4PickaxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage5PickaxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage6AxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage7ItemUUIDsToRemove: [UUID]?
	nonisolated(unsafe) var stage8PickaxeUUID: UUID?
	nonisolated(unsafe) var stage9PickaxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage10GoldUUIDsToRemove: [UUID]?

	nonisolated(unsafe) var stage1Stages: MineStage1Stages = .notStarted
	nonisolated(unsafe) var stage2Stages: MineStage2Stages = .notStarted
	nonisolated(unsafe) var stage3Stages: MineStage3Stages = .notStarted
	nonisolated(unsafe) var stage4Stages: MineStage4Stages = .notStarted {
		didSet {
			StatusBox.questBoxUpdate()
		}
	}

	nonisolated(unsafe) var stage5Stages: MineStage5Stages = .notStarted
	nonisolated(unsafe) var stage6Stages: MineStage6Stages = .notStarted {
		didSet {
			StatusBox.questBoxUpdate()
		}
	}

	nonisolated(unsafe) var stage7Stages: MineStage7Stages = .notStarted
	nonisolated(unsafe) var stage8Stages: MineStage8Stages = .notStarted
	nonisolated(unsafe) var stage9Stages: MineStage9Stages = .notStarted
	nonisolated(unsafe) var stage10Stages: MineStage10Stages = .notStarted {
		didSet {
			StatusBox.questBoxUpdate()
		}
	}

	mutating func next() {
		stageNumber += 1
	}
}
