import Foundation

struct Kingdom: Codable, Identifiable, Hashable, Equatable {
	let id: UUID
	// let name: String
	var buildings: [BuildingPosition]
	let npcsInKindom: [UUID]

	init(id: UUID = UUID(), buildings: [BuildingPosition], npcsInKindom: [UUID] = []) {
		self.id = id
		self.buildings = buildings
		self.npcsInKindom = npcsInKindom
	}
}

struct BuildingPosition: Codable, Hashable, Equatable {
	let x: Int
	let y: Int
	let type: DoorTileTypes
}
