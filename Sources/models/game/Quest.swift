enum Quest: Codable, Equatable {
    case chopLumber(count: Int = 10, for: String? = nil)

    //MARK: Blacksmith
    case blacksmith1

    //MARK: Mine
    case mine1
    case mine2
    case mine3

    var label: String {
        switch self {
            case .chopLumber(let count, let `for`):
                if let `for` {
                    return "Go get \(count) lumber for the \(`for`)"
                } else {
                    return "Go get \(count) lumber"
                }
            case .blacksmith1:
                return "Go get iron from the Mine and bring it to the blacksmith"
            case .mine1:
                return "Get a pickaxe from the blacksmith and bring it to the Miner"
            case .mine2:
                return "Mine 20 stone for the Miner"
            case .mine3:
                return "Mine 50 lumber for the Miner to upgrade the mine"
        }
    }
}
