enum StationTileType: Codable, Equatable {
	case furnace(progress: FurnaceProgress)
	case anvil

	var render: String {
		switch self {
			case let .furnace(progress: progress):
				switch progress {
					case .empty:
						"F".styled(with: .bold)
					case .inProgess:
						"F".styled(with: .red)
					case .finished:
						"F".styled(with: .green)
				}
			case .anvil:
				"a".styled(with: .bold)
		}
	}

	var name: String {
		switch self {
			case .furnace(progress: _):
				"furnace"
			case .anvil:
				"anvil"
		}
	}
}

enum FurnaceProgress: Int, Codable {
	case empty = 0
	case inProgess = 1
	case finished = 2
}
