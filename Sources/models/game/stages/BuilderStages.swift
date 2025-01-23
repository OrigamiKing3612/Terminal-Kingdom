import Foundation

struct BuilderStages: Codable {
	#if DEBUG
		private(set) nonisolated(unsafe) var stageNumber = 5
	#else
		private(set) nonisolated(unsafe) var stageNumber = 0
	#endif
	nonisolated(unsafe) var isDone: Bool { stageNumber > 10 }
	nonisolated(unsafe) var stage1ItemsUUIDsToRemove: [UUID]?
	nonisolated(unsafe) var stage2LumberUUIDToRemove: [UUID]?
	nonisolated(unsafe) var stage2AxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage3ItemsToMakeDoorUUIDsToRemove: [UUID]?
	nonisolated(unsafe) var stage3DoorUUIDToRemove: UUID?
	nonisolated(unsafe) var stage5HasBuiltHouse: Bool = false
	nonisolated(unsafe) var stage5BuildingsPlaced: Int = 0
	nonisolated(unsafe) var stage5LastBuildingPlaced: LastBuildingPlaced? {
		didSet {
			stage5BuildingsPlaced += 1
		}
	}

	nonisolated(unsafe) var stage5ItemsToBuildHouseUUIDsToRemove: [UUID]?
	nonisolated(unsafe) var stage6LumberUUIDToRemove: UUID?
	nonisolated(unsafe) var stage6AxeUUIDToRemove: UUID?
	nonisolated(unsafe) var stage7ItemsToBuildInsideUUIDsToRemove: [UUID]?
	nonisolated(unsafe) var stage7HasBuiltInside: Bool = false
	nonisolated(unsafe) var stage8_UUID: [UUID]?

	nonisolated(unsafe) var stage1Stages: BuilderStage1Stages = .notStarted
	nonisolated(unsafe) var stage2Stages: BuilderStage2Stages = .notStarted
	nonisolated(unsafe) var stage3Stages: BuilderStage3Stages = .notStarted
	nonisolated(unsafe) var stage4Stages: BuilderStage4Stages = .notStarted
	nonisolated(unsafe) var stage5Stages: BuilderStage5Stages = .notStarted
	#if DEBUG
		nonisolated(unsafe) var stage6Stages: BuilderStage6Stages = .done
	#else
		nonisolated(unsafe) var stage6Stages: BuilderStage6Stages = .notStarted
	#endif
	nonisolated(unsafe) var stage7Stages: BuilderStage7Stages = .notStarted
	nonisolated(unsafe) var stage8Stages: BuilderStage8Stages = .notStarted
	nonisolated(unsafe) var stage9Stages: BuilderStage9Stages = .notStarted
	nonisolated(unsafe) var stage10Stages: BuilderStage10Stages = .notStarted

	mutating func next() {
		stageNumber += 1
	}

	struct LastBuildingPlaced: Codable {
		var x: Int
		var y: Int
	}
}
