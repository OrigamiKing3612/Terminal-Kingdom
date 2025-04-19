import Foundation

actor StableBuilding: BuildingProtocol, NPCWorkplace {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	private var level: Int
	private var workers: Set<UUID> = []
	// private var animals: Set<UUID> = []

	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.id = id
		self.type = type
		self.level = 1
		self.x = x
		self.y = y
	}

	func getLevel() async -> Int { level }

	func setLevel(newLevel: Int) async {
		guard newLevel > 0 else {
			return
		}
		level = newLevel
	}

	func hire(_ worker: UUID) async {
		guard await workers.count < getMaxWorkers() else {
			return
		}
		workers.insert(worker)
	}

	func fire(_ worker: UUID) async {
		workers.remove(worker)
	}

	func getWorkers() async -> Set<UUID> { workers }
}
