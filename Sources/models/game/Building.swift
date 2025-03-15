import Foundation

struct Building: Codable, Equatable, Hashable, Identifiable {
	let id: UUID
	let x: Int
	let y: Int
	let type: DoorTileTypes
	private(set) var level: Int

	init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.id = id
		self.type = type
		self.level = 1
		self.x = x
		self.y = y
	}
}
