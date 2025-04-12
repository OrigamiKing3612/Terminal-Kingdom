import Foundation

actor Building: BuildingProtocol {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	private var level: Int

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
}
