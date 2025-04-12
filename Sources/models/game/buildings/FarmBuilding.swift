import Foundation

actor FarmBuilding: BuildingProtocol {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	private var level: Int
	private(set) var pots: Int = 0

	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.pots = 0
		self.id = id
		self.type = type
		self.level = 1
		self.x = x
		self.y = y
	}

	func addPot() async {
		pots += 1
	}

	func removePot() async {
		pots -= 1
	}

	func getLevel() async -> Int { level }

	func setLevel(newLevel: Int) async {
		guard newLevel > 0 else {
			return
		}
		level = newLevel
	}
}
