enum DoorPlaceError: Error {
	case noDoor
	case noSpace
	case notEnoughBuildingsNearby

	var localizedDescription: String {
		switch self {
			case .noDoor: "You don't have a door to place."
			case .noSpace: "You can only place a door on a plain tile."
			case .notEnoughBuildingsNearby: "There must be at least 3 buildings that you placed nearby."
		}
	}
}
