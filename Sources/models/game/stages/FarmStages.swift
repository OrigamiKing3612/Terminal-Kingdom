import Foundation

struct FarmStages: Codable {
	private(set) var stageNumber = 0
	nonisolated(unsafe) var stage1Stages: FarmStage1Stages = .notStarted

	mutating func next() {
		stageNumber += 1
	}
}
