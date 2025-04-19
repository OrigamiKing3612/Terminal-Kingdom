struct Skill: Codable {
	var blacksmithing: SkillLevel
	var mining: SkillLevel
	var carpentry: SkillLevel
	var farming: SkillLevel
	var building: SkillLevel
	var sales: SkillLevel
	var hunting: SkillLevel
	var inventing: SkillLevel
	var caretaking: SkillLevel
	var medicine: SkillLevel
	var cooking: SkillLevel

	init(blacksmithing: SkillLevel = .none, mining: SkillLevel = .none, carpentry: SkillLevel = .none, farming: SkillLevel = .none, building: SkillLevel = .none, sales: SkillLevel = .none, hunting: SkillLevel = .none, inventing: SkillLevel = .none, caretaking: SkillLevel = .none, medicine: SkillLevel = .none, cooking: SkillLevel = .none) {
		self.blacksmithing = blacksmithing
		self.mining = mining
		self.carpentry = carpentry
		self.farming = farming
		self.building = building
		self.sales = sales
		self.hunting = hunting
		self.inventing = inventing
		self.caretaking = caretaking
		self.medicine = medicine
		self.cooking = cooking
	}

	func allSkills() -> [(String, SkillLevel)] {
		[
			("Blacksmithing", blacksmithing),
			("Mining", mining),
			("Carpentry", carpentry),
			("Farming", farming),
			("Building", building),
			("Sales", sales),
			("Hunting", hunting),
			("Inventing", inventing),
			("Caretaking", caretaking),
			("Medicine", medicine),
			("Cooking", cooking),
		]
	}

	mutating func increaseBlacksmithing() {
		blacksmithing = blacksmithing.getNext
	}

	mutating func increaseMining() {
		mining = mining.getNext
	}

	mutating func increaseCarpentry() {
		carpentry = carpentry.getNext
	}

	mutating func increaseFarming() {
		farming = farming.getNext
	}

	mutating func increaseBuilding() {
		building = building.getNext
	}

	mutating func increaseSales() {
		sales = sales.getNext
	}

	mutating func increaseHunting() {
		hunting = hunting.getNext
	}

	mutating func increaseInventing() {
		inventing = inventing.getNext
	}

	mutating func increaseCaretaking() {
		caretaking = caretaking.getNext
	}

	mutating func increaseMedicine() {
		medicine = medicine.getNext
	}

	mutating func increaseCooking() {
		cooking = cooking.getNext
	}

	static func random() -> Self {
		var skills = Array(1 ... 11)
		let a = skills.remove(at: Int.random(in: 0 ..< skills.count))
		let b = skills.remove(at: Int.random(in: 0 ..< skills.count))
		let hasB = Int.random(in: 1 ... 10) == 1

		let levelA = SkillLevel.random()
		let levelB = SkillLevel.random()

		var skillLevels: [Int: SkillLevel] = [:]
		skillLevels[a] = levelA
		if hasB {
			skillLevels[b] = levelB
		}

		return Skill(
			blacksmithing: skillLevels[1] ?? .none,
			mining: skillLevels[2] ?? .none,
			carpentry: skillLevels[3] ?? .none,
			farming: skillLevels[4] ?? .none,
			building: skillLevels[5] ?? .none,
			sales: skillLevels[6] ?? .none,
			hunting: skillLevels[7] ?? .none,
			inventing: skillLevels[8] ?? .none,
			caretaking: skillLevels[9] ?? .none,
			medicine: skillLevels[10] ?? .none,
			cooking: skillLevels[11] ?? .none
		)
	}
}

enum SkillLevel: Codable, CaseIterable {
	case none
	case novice
	case apprentice
	case journeyman
	case expert
	case master

	static func random() -> Self {
		let x = Int.random(in: 1 ... 100)
		switch x {
			case 1 ... 40:
				return .none
			case 41 ... 70:
				return .novice
			case 71 ... 80:
				return .apprentice
			case 81 ... 90:
				return .journeyman
			case 91 ... 97:
				return .expert
			case 98 ... 100:
				return .master
			default:
				return .none
		}
	}

	var name: String {
		switch self {
			case .none:
				"None"
			case .novice:
				"Novice"
			case .apprentice:
				"Apprentice"
			case .journeyman:
				"Journeyman"
			case .expert:
				"Expert"
			case .master:
				"Master"
		}
	}

	var getNext: Self {
		switch self {
			case .none:
				.novice
			case .novice:
				.apprentice
			case .apprentice:
				.journeyman
			case .journeyman:
				.expert
			case .expert:
				.master
			case .master:
				.master
		}
	}
}
