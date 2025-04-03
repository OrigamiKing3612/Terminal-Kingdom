enum Hunger: Codable, CaseIterable {
	case starving
	case hungry
	case could_eat
	case full

	var name: String {
		switch self {
			case .starving:
				"Starving"
			case .hungry:
				"Hungry"
			case .could_eat:
				"Could Eat"
			case .full:
				"Full"
		}
	}

	static func hunger(for hunger: Double) -> Hunger {
		switch hunger {
			case 0 ..< 25:
				.starving
			case 25 ..< 50:
				.hungry
			case 50 ..< 75:
				.could_eat
			case 75 ..< 100:
				.full
			default:
				.full
		}
	}
}
