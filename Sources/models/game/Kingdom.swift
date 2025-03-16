import Foundation

struct Kingdom: Codable, Identifiable, Hashable, Equatable {
	let id: UUID
	var name: String
	var buildings: [Building]
	var npcsInKindom: [UUID]
	var hasCastle: Bool = false
	var data: [KingdomData] = []
	// private(set) var radius: Int = 50
	private(set) var radius: Int = 20
	var castleID: UUID? = nil

	init(id: UUID = UUID(), name: String, buildings: [Building], npcsInKindom: [UUID] = []) {
		self.id = id
		self.buildings = buildings
		self.npcsInKindom = npcsInKindom
		self.name = name
	}

	mutating func addData(_ data: KingdomData) {
		self.data.append(data)
	}

	mutating func removeData(_ data: KingdomData) {
		self.data.removeAll { $0 == data }
	}

	mutating func setHasCastle() {
		hasCastle = true
		let castleID = getCastle()?.id
		if let castleID {
			self.castleID = castleID
		}
	}

	mutating func removeCastle() {
		hasCastle = false
		castleID = nil
	}

	func getCastle() -> Building? {
		guard hasCastle else {
			return nil
		}
		// index 1 should be castle beucase it is the second building added
		if case .castle = buildings[1].type {
			return buildings[1]
		}

		// Otherwise, search for any castle
		return buildings.first { b in
			// if case let .custom(_, doorType: doorType) = b.type {
			if case .castle = b.type {
				// if case .castle = doorType {
				return true
				// }
			}
			return false
		}
	}
}

enum KingdomData: Codable, Hashable {
	case buildingCastle, gettingStuffToBuildCastle
}
