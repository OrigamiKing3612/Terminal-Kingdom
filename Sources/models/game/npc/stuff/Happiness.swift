enum Happiness: Codable, CaseIterable {
	case angry
	case sad
	case could_be_better
	case ok
	case happy

	var name: String {
		switch self {
			case .angry:
				"Angry"
			case .sad:
				"Sad"
			case .could_be_better:
				"Could Be Better"
			case .ok:
				"Ok"
			case .happy:
				"Happy"
		}
	}

	static func happiness(for happiness: Double) -> Self {
		switch happiness {
			case 0 ..< 20:
				.angry
			case 20 ..< 40:
				.sad
			case 40 ..< 60:
				.could_be_better
			case 60 ..< 80:
				.ok
			case 80 ..< 100:
				.happy
			default:
				.happy
		}
	}
}
