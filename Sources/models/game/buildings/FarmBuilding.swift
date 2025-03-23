import Foundation

struct FarmBuilding: BuildingProtocol {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	var level: Int
	private(set) var pots: Int = 0

	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.pots = 0
		self.id = id
		self.type = type
		self.level = 1
		self.x = x
		self.y = y
	}

	mutating func addPot() async {
		pots += 1
	}

	mutating func removePot() async {
		pots -= 1
	}
}
