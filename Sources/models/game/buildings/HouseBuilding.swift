import Foundation

actor HouseBuilding: BuildingProtocol {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	private var level: Int
	private(set) var residents: Set<UUID> = []
	var maxResidents: Int {
		level
	}

	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.id = id
		self.type = type
		self.level = 1
		self.x = x
		self.y = y
	}

	func addResident(_ resident: UUID) async {
		guard residents.count < maxResidents else {
			return
		}
		residents.insert(resident)
		await Game.shared.npcs.addHappiness(npcID: resident, amount: 4)
	}

	func removeResident(_ resident: UUID) async {
		residents.remove(resident)
		await Game.shared.npcs.removeHappiness(npcID: resident, amount: 5)
	}

	func getLevel() async -> Int { level }
	func setLevel(newLevel: Int) async {
		guard newLevel > level else {
			return
		}
		level = newLevel
	}
}
