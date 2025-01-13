import Foundation

struct BuilderStages: Codable {
	private(set) var stageNumber = 0
	var isDone: Bool { stageNumber > 10 }
	var stage1ItemsUUIDToRemove: [UUID]?
	var stage2LumberUUIDToRemove: [UUID]?
	var stage2AxeUUIDToRemove: UUID?
	var stage3ItemsUUIDToRemove: [UUID]?
	var stage3DoorUUIDToRemove: UUID?
	var stage5_UUIDToRemove: [UUID]?
	var stage6LumberUUIDToRemove: UUID?
	var stage7_UUIDsToRemove: [UUID]?
	var stage8_UUID: [UUID]?

	var stage1Stages: BuilderStage1Stages = .notStarted
	var stage2Stages: BuilderStage2Stages = .notStarted
	var stage3Stages: BuilderStage3Stages = .notStarted
	var stage4Stages: BuilderStage4Stages = .notStarted
	var stage5Stages: BuilderStage5Stages = .notStarted
	var stage6Stages: BuilderStage6Stages = .notStarted
	var stage7Stages: BuilderStage7Stages = .notStarted
	var stage8Stages: BuilderStage8Stages = .notStarted
	var stage9Stages: BuilderStage9Stages = .notStarted
	var stage10Stages: BuilderStage10Stages = .notStarted

	mutating func next() {
		stageNumber += 1
	}
}
