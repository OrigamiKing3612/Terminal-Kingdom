struct Stats: Codable {
	var skill: Skill = .init()

	private(set) var mineLevel: MineLevel = .one {
		didSet {
			if mineLevel.rawValue < oldValue.rawValue {
				mineLevel = oldValue
			}
		}
	}

	mutating func setMineLevel(_ level: MineLevel) {
		mineLevel = level
	}
}

extension PlayerCharacter {
	func setMineLevel(_ level: MineLevel) {
		stats.setMineLevel(level)
	}

	func setBlacksmithingSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setBlacksmithing(newValue)
	}

	func setMiningSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setMining(newValue)
	}

	func setCarpentrySkillLevel(_ newValue: SkillLevel) {
		stats.skill.setCarpentry(newValue)
	}

	func setFarmingSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setFarming(newValue)
	}

	func setBuildingSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setBuilding(newValue)
	}

	func setSalesSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setSales(newValue)
	}

	func setHuntingSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setHunting(newValue)
	}

	func setInventingSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setInventing(newValue)
	}

	func setCaretakingSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setCaretaking(newValue)
	}

	func setMedicineSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setMedicine(newValue)
	}

	func setCookingSkillLevel(_ newValue: SkillLevel) {
		stats.skill.setCooking(newValue)
	}
}

enum MineLevel: Int, Codable, CaseIterable {
	case one = 1
	case two = 2
	case three = 3
}
