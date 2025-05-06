import Foundation

struct SkillProgress: Codable {
	var level: SkillLevel
	var experience: Double

	mutating func addExperience(_ amount: Double) {
		experience += amount
		if experience >= (100 * level.multiplier) {
			level = level.getNext
			experience = 0
		}
	}

	mutating func setLevel(_ newLevel: SkillLevel) {
		level = newLevel
	}

	enum SkillLevel: Codable, CaseIterable {
		case none
		case novice
		case apprentice
		case journeyman
		case expert
		case master

		var multiplier: Double {
			switch self {
				case .none:
					1
				case .novice:
					1
				case .apprentice:
					1.5
				case .journeyman:
					2
				case .expert:
					3
				case .master:
					4
			}
		}

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
}
