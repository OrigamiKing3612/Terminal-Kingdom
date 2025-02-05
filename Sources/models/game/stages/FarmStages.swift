import Foundation

actor FarmStages {
	private(set) var stageNumber = 0
	private(set) var stage1AxeUUIDToRemove: UUID?
	private(set) var stage1SeedUUIDToRemove: UUID?

	private(set) var stage1Stages: FarmStage1Stages = .notStarted
	private(set) var stage2Stages: FarmStage2Stages = .notStarted

	func next() {
		stageNumber += 1
	}

	func setStage1AxeUUIDsToRemove(_ uuid: UUID) {
		stage1AxeUUIDToRemove = uuid
	}

	func setStage2SeedUUIDsToRemove(_ uuid: UUID) {
		stage1SeedUUIDToRemove = uuid
	}

	func setStage1Stages(_ stage: FarmStage1Stages) {
		stage1Stages = stage
	}

	func setStage2Stages(_ stage: FarmStage2Stages) {
		stage2Stages = stage
	}
}
