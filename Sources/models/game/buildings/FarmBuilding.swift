import Foundation

class FarmBuilding: Building, @unchecked Sendable {
	private(set) var pots: Int

	override init(id: UUID = UUID(), type: DoorTileTypes, x: Int, y: Int) {
		self.pots = 0
		super.init(id: id, type: type, x: x, y: y)
	}

	func addPot() async {
		pots += 1
	}

	func removePot() async {
		pots -= 1
	}

	enum CodingKeys: CodingKey {
		case pots
	}

	required init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: FarmBuilding.CodingKeys.self)

		self.pots = try container.decode(Int.self, forKey: .pots)
		try super.init(from: decoder)
	}

	override func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: FarmBuilding.CodingKeys.self)

		try container.encode(pots, forKey: .pots)

		try super.encode(to: encoder)
	}
}
