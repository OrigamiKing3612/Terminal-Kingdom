import Foundation

struct HouseBuilding: BuildingProtocol {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	var level: Int
	private(set) var residents: [UUID] = []

	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.id = id
		self.type = type
		self.level = 1
		self.x = x
		self.y = y
	}

	mutating func addResident(_ resident: UUID) async {
		residents.append(resident)
	}

	mutating func removeResident(_ resident: UUID) async {
		residents.removeAll(where: { $0 == resident })
	}
}
