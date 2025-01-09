struct Stats: Codable {
	nonisolated(unsafe) var blacksmithSkillLevel: SkillLevels = .zero
	nonisolated(unsafe) var miningSkillLevel: SkillLevels = .zero
	nonisolated(unsafe) var builderSkillLevel: SkillLevels = .zero // architect?
	nonisolated(unsafe) var huntingSkillLevel: SkillLevels = .zero
	nonisolated(unsafe) var inventorSkillLevel: SkillLevels = .zero
	nonisolated(unsafe) var stableSkillLevel: SkillLevels = .zero
	nonisolated(unsafe) var farmingSkillLevel: SkillLevels = .zero
	nonisolated(unsafe) var medicalSkillLevel: SkillLevels = .zero
	nonisolated(unsafe) var carpentrySkillLevel: SkillLevels = .zero
	nonisolated(unsafe) var cookingSkillLevel: SkillLevels = .zero
	nonisolated(unsafe) var mineLevel: MineLevel = .one {
		didSet {
			if mineLevel.rawValue < oldValue.rawValue {
				mineLevel = oldValue
			}
		}
	}
}

enum AllSkillLevels: CaseIterable {
	case blacksmithSkillLevel
	case miningSkillLevel
	case builderSkillLevel
	case huntingSkillLevel
	case inventorSkillLevel
	case stableSkillLevel
	case farmingSkillLevel
	case medicalSkillLevel
	case carpentrySkillLevel

	var stat: SkillLevels {
		switch self {
			case .blacksmithSkillLevel:
				Game.player.stats.blacksmithSkillLevel
			case .miningSkillLevel:
				Game.player.stats.miningSkillLevel
			case .builderSkillLevel:
				Game.player.stats.builderSkillLevel
			case .huntingSkillLevel:
				Game.player.stats.huntingSkillLevel
			case .inventorSkillLevel:
				Game.player.stats.inventorSkillLevel
			case .stableSkillLevel:
				Game.player.stats.stableSkillLevel
			case .farmingSkillLevel:
				Game.player.stats.farmingSkillLevel
			case .medicalSkillLevel:
				Game.player.stats.medicalSkillLevel
			case .carpentrySkillLevel:
				Game.player.stats.carpentrySkillLevel
		}
	}

	var name: String {
		switch self {
			case .blacksmithSkillLevel:
				"Blacksmith Skill Level"
			case .miningSkillLevel:
				"Mining Skill Level"
			case .builderSkillLevel:
				"Builder Skill Level"
			case .huntingSkillLevel:
				"Hunting Skill Level"
			case .inventorSkillLevel:
				"Inventor Skill Level"
			case .stableSkillLevel:
				"Stable Skill Level"
			case .farmingSkillLevel:
				"Farming Skill Level"
			case .medicalSkillLevel:
				"Medical Skill Level"
			case .carpentrySkillLevel:
				"Carpentry Skill Level"
		}
	}
}

enum SkillLevels: Int, Codable {
	case zero = 0
	case one = 1
	case two = 2
	case three = 3
	case four = 4
	case five = 5
	case six = 6
	case seven = 7
	case eight = 8
	case nine = 9
	case ten = 10
}

enum MineLevel: Int, Codable, CaseIterable {
	case one = 1
	case two = 2
	case three = 3
}
