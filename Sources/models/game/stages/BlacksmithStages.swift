import Foundation

struct BlacksmithStages: Codable {
	private(set) var stageNumber = 0
	nonisolated(unsafe) var stage1AIronUUIDsToRemove: [UUID]?
	nonisolated(unsafe) var stage2AxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage3LumberUUIDsToRemove: [UUID]?
	nonisolated(unsafe) var stage4CoalUUIDsToRemove: [UUID]?
	nonisolated(unsafe) var stage5ItemsToMakeSteelUUIDs: [UUID]?
	nonisolated(unsafe) var stage5SteelUUIDsToRemove: [UUID] = []
	nonisolated(unsafe) var stage6ItemsToMakePickaxeUUIDs: [UUID]?
	nonisolated(unsafe) var stage6PickaxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage7ItemsToMakeSwordUUIDs: [UUID]?
	nonisolated(unsafe) var stage7SwordUUIDToRemove: UUID?
	nonisolated(unsafe) var stage8MaterialsToRemove: [UUID]?
	nonisolated(unsafe) var stage9SteelUUIDToRemove: [UUID]?

	nonisolated(unsafe) var stage1Stages: BlacksmithStage1Stages = .notStarted
	nonisolated(unsafe) var stage2Stages: BlacksmithStage2Stages = .notStarted
	nonisolated(unsafe) var stage3Stages: BlacksmithStage3Stages = .notStarted
	nonisolated(unsafe) var stage4Stages: BlacksmithStage4Stages = .notStarted
	nonisolated(unsafe) var stage5Stages: BlacksmithStage5Stages = .notStarted
	nonisolated(unsafe) var stage6Stages: BlacksmithStage6Stages = .notStarted
	nonisolated(unsafe) var stage7Stages: BlacksmithStage7Stages = .notStarted
	nonisolated(unsafe) var stage8Stages: BlacksmithStage8Stages = .notStarted
	var stage9Stages: BlacksmithStage9Stages = .notStarted

	mutating func next() {
		stageNumber += 1
	}
}
