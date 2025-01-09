import Foundation

struct Stages: Codable {
	// MARK: Blacksmith

	var random: RandomStages = .init()
	var blacksmith: BlacksmithStages = .init()
	var mine: MineStages = .init()
	var farm: FarmStages = .init()
}

struct RandomStages: Codable {
	var chopTreeAxeUUIDToRemove: UUID?
}
