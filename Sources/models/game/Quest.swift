enum Quest: Codable, Equatable {
    case chopLumber(count: Int, for: String? = nil)
    
    //MARK: Blacksmith
    case blacksmith1
    
    //MARK: Mine
    case mine1
    
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
                return "Mine 20 stone for the miner"
        }
    }
}
