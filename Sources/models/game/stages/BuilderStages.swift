import Foundation

struct BuilderStages: Codable {
	#if DEBUG
		private(set) var stageNumber = 5
	#else
		private(set) var stageNumber = 0
	#endif
	var isDone: Bool { stageNumber > 10 }
	var stage1ItemsUUIDsToRemove: [UUID]?
	var stage2LumberUUIDToRemove: [UUID]?
	var stage2AxeUUIDToRemove: UUID?
	var stage3ItemsToMakeDoorUUIDsToRemove: [UUID]?
	var stage3DoorUUIDToRemove: UUID?
	var stage5HasBuiltHouse: Bool = false
	var stage5BuildingsPlaced: Int = 0
	var stage5LastBuildingPlaced: LastBuildingPlaced? {
		didSet {
			stage5BuildingsPlaced += 1
		}
	}

	var stage5ItemsToBuildHouseUUIDsToRemove: [UUID]?
	var stage6LumberUUIDToRemove: UUID?
	var stage6AxeUUIDToRemove: UUID?
	var stage7ItemsToBuildInsideUUIDsToRemove: [UUID]?
	var stage7HasBuiltInside: Bool = false
	var stage8_UUID: [UUID]?

	var stage1Stages: BuilderStage1Stages = .notStarted
	var stage2Stages: BuilderStage2Stages = .notStarted
	var stage3Stages: BuilderStage3Stages = .notStarted
	var stage4Stages: BuilderStage4Stages = .notStarted
	var stage5Stages: BuilderStage5Stages = .notStarted
	#if DEBUG
		var stage6Stages: BuilderStage6Stages = .done
	#else
		var stage6Stages: BuilderStage6Stages = .notStarted
	#endif
	var stage7Stages: BuilderStage7Stages = .notStarted
	var stage8Stages: BuilderStage8Stages = .notStarted
	var stage9Stages: BuilderStage9Stages = .notStarted
	var stage10Stages: BuilderStage10Stages = .notStarted

	mutating func next() {
		stageNumber += 1
	}

	struct LastBuildingPlaced: Codable {
		var x: Int
		var y: Int
	}
}
