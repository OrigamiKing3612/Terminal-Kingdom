struct Skill: Codable {
	var blacksmithing: SkillProgress
	var mining: SkillProgress
	var carpentry: SkillProgress
	var farming: SkillProgress
	var building: SkillProgress
	var sales: SkillProgress
	var hunting: SkillProgress
	var inventing: SkillProgress
	var caretaking: SkillProgress
	var medicine: SkillProgress
	var cooking: SkillProgress

	init(blacksmithing: SkillProgress.SkillLevel = .none, mining: SkillProgress.SkillLevel = .none, carpentry: SkillProgress.SkillLevel = .none, farming: SkillProgress.SkillLevel = .none, building: SkillProgress.SkillLevel = .none, sales: SkillProgress.SkillLevel = .none, hunting: SkillProgress.SkillLevel = .none, inventing: SkillProgress.SkillLevel = .none, caretaking: SkillProgress.SkillLevel = .none, medicine: SkillProgress.SkillLevel = .none, cooking: SkillProgress.SkillLevel = .none) {
		self.blacksmithing = .init(level: blacksmithing, experience: 0)
		self.mining = .init(level: mining, experience: 0)
		self.carpentry = .init(level: carpentry, experience: 0)
		self.farming = .init(level: farming, experience: 0)
		self.building = .init(level: building, experience: 0)
		self.sales = .init(level: sales, experience: 0)
		self.hunting = .init(level: hunting, experience: 0)
		self.inventing = .init(level: inventing, experience: 0)
		self.caretaking = .init(level: caretaking, experience: 0)
		self.medicine = .init(level: medicine, experience: 0)
		self.cooking = .init(level: cooking, experience: 0)
	}

	func allSkills() -> [(String, SkillProgress.SkillLevel)] {
		[
			("Blacksmithing", blacksmithing.level),
			("Mining", mining.level),
			("Carpentry", carpentry.level),
			("Farming", farming.level),
			("Building", building.level),
			("Sales", sales.level),
			("Hunting", hunting.level),
			("Inventing", inventing.level),
			("Caretaking", caretaking.level),
			("Medicine", medicine.level),
			("Cooking", cooking.level),
		]
	}

	mutating func increaseBlacksmithing(xp: Double) {
		blacksmithing.addExperience(xp)
	}

	mutating func increaseMining(xp: Double) {
		mining.addExperience(xp)
	}

	mutating func increaseCarpentry(xp: Double) {
		carpentry.addExperience(xp)
	}

	mutating func increaseFarming(xp: Double) {
		farming.addExperience(xp)
	}

	mutating func increaseBuilding(xp: Double) {
		building.addExperience(xp)
	}

	mutating func increaseSales(xp: Double) {
		sales.addExperience(xp)
	}

	mutating func increaseHunting(xp: Double) {
		hunting.addExperience(xp)
	}

	mutating func increaseInventing(xp: Double) {
		inventing.addExperience(xp)
	}

	mutating func increaseCaretaking(xp: Double) {
		caretaking.addExperience(xp)
	}

	mutating func increaseMedicine(xp: Double) {
		medicine.addExperience(xp)
	}

	mutating func increaseCooking(xp: Double) {
		cooking.addExperience(xp)
	}

	mutating func setBlacksmithing(_ newValue: SkillProgress) {
		blacksmithing = newValue
	}

	mutating func setMining(_ newValue: SkillProgress) {
		mining = newValue
	}

	mutating func setCarpentry(_ newValue: SkillProgress) {
		carpentry = newValue
	}

	mutating func setFarming(_ newValue: SkillProgress) {
		farming = newValue
	}

	mutating func setBuilding(_ newValue: SkillProgress) {
		building = newValue
	}

	mutating func setSales(_ newValue: SkillProgress) {
		sales = newValue
	}

	mutating func setHunting(_ newValue: SkillProgress) {
		hunting = newValue
	}

	mutating func setInventing(_ newValue: SkillProgress) {
		inventing = newValue
	}

	mutating func setCaretaking(_ newValue: SkillProgress) {
		caretaking = newValue
	}

	mutating func setMedicine(_ newValue: SkillProgress) {
		medicine = newValue
	}

	mutating func setCooking(_ newValue: SkillProgress) {
		cooking = newValue
	}

	mutating func setBlacksmithing(_ newValue: SkillProgress.SkillLevel) {
		blacksmithing.setLevel(newValue)
	}

	mutating func setMining(_ newValue: SkillProgress.SkillLevel) {
		mining.setLevel(newValue)
	}

	mutating func setCarpentry(_ newValue: SkillProgress.SkillLevel) {
		carpentry.setLevel(newValue)
	}

	mutating func setFarming(_ newValue: SkillProgress.SkillLevel) {
		farming.setLevel(newValue)
	}

	mutating func setBuilding(_ newValue: SkillProgress.SkillLevel) {
		building.setLevel(newValue)
	}

	mutating func setSales(_ newValue: SkillProgress.SkillLevel) {
		sales.setLevel(newValue)
	}

	mutating func setHunting(_ newValue: SkillProgress.SkillLevel) {
		hunting.setLevel(newValue)
	}

	mutating func setInventing(_ newValue: SkillProgress.SkillLevel) {
		inventing.setLevel(newValue)
	}

	mutating func setCaretaking(_ newValue: SkillProgress.SkillLevel) {
		caretaking.setLevel(newValue)
	}

	mutating func setMedicine(_ newValue: SkillProgress.SkillLevel) {
		medicine.setLevel(newValue)
	}

	mutating func setCooking(_ newValue: SkillProgress.SkillLevel) {
		cooking.setLevel(newValue)
	}

	static func random() -> Self {
		var skills = Array(1 ... 11)
		let a = skills.remove(at: Int.random(in: 0 ..< skills.count))
		let b = skills.remove(at: Int.random(in: 0 ..< skills.count))
		let hasB = Int.random(in: 1 ... 10) == 1

		let levelA = SkillProgress.SkillLevel.random()
		let levelB = SkillProgress.SkillLevel.random()

		var skillLevels: [Int: SkillProgress.SkillLevel] = [:]
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
