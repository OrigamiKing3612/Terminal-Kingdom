import Foundation

actor BlacksmithBuilding: BuildingProtocol {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	private var level: Int
	private(set) var furnaces: Int = 0
	private(set) var anvils: Int = 0

	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.furnaces = 0
		self.anvils = 0
		self.id = id
		self.type = type
		self.level = 1
		self.x = x
		self.y = y
	}

	func addFurnace() async {
		furnaces += 1
	}

	func removeFurnace() async {
		furnaces -= 1
	}

	func addAnvil() async {
		anvils += 1
	}

	func removeAnvil() async {
		anvils -= 1
	}

	func getLevel() async -> Int { level }

	func setLevel(newLevel: Int) async {
		guard newLevel > 0 else {
			return
		}
		level = newLevel
	}
}
