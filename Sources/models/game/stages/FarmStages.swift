import Foundation

actor FarmStages {
	private(set) var stageNumber = 0
	private(set) var stage1Stages: FarmStage1Stages = .notStarted

	func next() {
		stageNumber += 1
	}

	func setStage1Stages(_ stage: FarmStage1Stages) {
		stage1Stages = stage
	}
}
