import Foundation

actor MineBuilding: BuildingProtocol, NPCWorkplace {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	private var level: Int
	private var workers: Set<UUID> = []
	private(set) var entrances: Int = 0

	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.entrances = 0
		self.id = id
		self.type = type
		self.level = 1
		self.x = x
		self.y = y
	}

	func addEntrance() async {
		entrances += 1
	}

	func removeEntrance() async {
		entrances -= 1
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
