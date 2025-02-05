import Foundation

actor FarmStages {
	private(set) var stageNumber = 0
	private(set) var stage1AxeUUIDsToRemove: UUID?

	private(set) var stage1Stages: FarmStage1Stages = .notStarted

	func next() {
		stageNumber += 1
	}

	func setStage1AxeUUIDsToRemove(_ uuid: UUID) {
		stage1AxeUUIDsToRemove = uuid
	}

	func setStage1Stages(_ stage: FarmStage1Stages) {
		stage1Stages = stage
	}
}
