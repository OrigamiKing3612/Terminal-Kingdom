import Foundation

struct Kingdom: Codable, Identifiable, Hashable, Equatable {
	let id: UUID
	// let name: String
	var buildings: [Building]
	var npcsInKindom: [UUID]
	var hasCastle: Bool = false
	var data: [KingdomData] = []

	init(id: UUID = UUID(), buildings: [Building], npcsInKindom: [UUID] = []) {
		self.id = id
		self.buildings = buildings
		self.npcsInKindom = npcsInKindom
	}

	mutating func addData(_ data: KingdomData) {
		self.data.append(data)
	}

	mutating func removeData(_ data: KingdomData) {
		self.data.removeAll { $0 == data }
	}
}

enum KingdomData: Codable, Hashable {
	case buildingCastle
}
