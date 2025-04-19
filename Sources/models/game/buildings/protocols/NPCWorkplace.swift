import Foundation

protocol NPCWorkplace: BuildingProtocol {
	// var workers: Set<UUID> { get set }
	func isHiring() async -> Bool
	func hire(_ worker: UUID) async
	func fire(_ worker: UUID) async
	func getWorkers() async -> Set<UUID>
	func getMaxWorkers() async -> Int
}

extension NPCWorkplace {
	func isHiring() async -> Bool {
		let maxWorkers = await getMaxWorkers()
		let currentWorkers = await getWorkers().count
		return currentWorkers < maxWorkers
	}

	func getMaxWorkers() async -> Int {
		let level = await getLevel()
		return level * 2
	}
}
