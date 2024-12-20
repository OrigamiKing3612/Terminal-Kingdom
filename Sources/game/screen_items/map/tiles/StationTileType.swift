enum StationTileType: Codable, Equatable {
    case furnace(progress: FurnaceProgress)
    case anvil

    var render: String {
        switch self {
            case .furnace(progress: let progress):
                switch progress {
                    case .empty:
                        return "F".styled(with: .bold)
                    case .inProgess:
                        return "F".styled(with: .red)
                    case .finished:
                        return "F".styled(with: .green)
                }
            case .anvil:
                return "a".styled(with: .bold)
        }
    }
    var name: String {
        switch self {
            case .furnace(progress: _):
                return "furnace"
            case .anvil:
                return "anvil"
        }
    }
}

enum FurnaceProgress: Int, Codable {
    case empty = 0
    case inProgess = 1
    case finished = 2
}
