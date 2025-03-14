import Foundation

struct Kingdom: Codable, Identifiable, Hashable, Equatable {
	let id: UUID
	// let name: String
	var buildings: [BuildingPosition]
	// let npcs: [NPCTile]

	init(id: UUID = UUID(), buildings: [BuildingPosition]) {
		self.id = id
		self.buildings = buildings
	}
}

struct BuildingPosition: Codable, Hashable, Equatable {
	let x: Int
	let y: Int
	let type: DoorTileTypes
}
