import Foundation

struct Kingdom: Codable, Identifiable, Hashable, Equatable {
	let id: UUID
	// let name: String
	var buildings: [Building]
	var npcsInKindom: [UUID]

	init(id: UUID = UUID(), buildings: [Building], npcsInKindom: [UUID] = []) {
		self.id = id
		self.buildings = buildings
		self.npcsInKindom = npcsInKindom
	}
}
