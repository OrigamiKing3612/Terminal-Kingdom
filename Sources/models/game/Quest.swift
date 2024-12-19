enum Quest: Codable, Equatable {
    case chopLumber(count: Int = 10, for: String? = nil)

    //MARK: Blacksmith
    case blacksmith1
    case blacksmith2
    case blacksmith3
    case blacksmith4
    case blacksmith5
    case blacksmith6
    case blacksmith7
    case blacksmith8
    case blacksmith9
    case blacksmith10

    //MARK: Mine
    case mine1
    case mine2
    case mine3
    case mine4
    case mine5
    case mine6
    case mine7
    case mine8
    case mine9
    case mine10

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
            case .blacksmith2:
                return "Go get 20 lumber and band bring it to the blacksmith"
            case .blacksmith3:
                return "Bring Lumber to the carpenter and bring it back to the blacksmith"
            case .blacksmith4:
                return "Get 5 coal from the miner"
            case .blacksmith5:
                return "Use the furnace to make steel"
            case .blacksmith6:
                return "Make a pickaxe on the anvil"
            case .blacksmith7:
                switch Game.stages.blacksmith.stage7Stages {
                    case .notStarted:
                        return "Blacksmith Stage 7 not started"
                    case .makeSword:
                        return "Make a sword on the anvil"
                    case .bringToHunter:
                        return "Bring the sword to the hunter"
                    case .done:
                        return "Blacksmith Stage 7 done"
                }
            case .blacksmith8:
                return "Get materials for steel and make some"
            case .blacksmith9:
                return "Sell the steel in the shop"
            case .blacksmith10:
                return "Collect gift from the blacksmith"
            case .mine1:
                return "Get a pickaxe from the blacksmith and bring it to the Miner"
            case .mine2:
                return "Mine 20 clay for the Miner"
            case .mine3:
                return "Mine 50 lumber for the Miner to upgrade the mine"
            case .mine4:
                switch Game.stages.mine.stage4Stages {
                    case .notStarted:
                        return "Mine Stage 4 not started"
                    case .collectPickaxe:
                        return "Get a pickaxe from the blacksmith"
                    case .mine:
                        return "Mine 30 stone for the Miner"
                    case .done:
                        return "Mine Stage 4 done"
                }
            case .mine5:
                return "Mine 20 iron for the Miner"
            case .mine6:
                switch Game.stages.mine.stage6Stages {
                    case .notStarted:
                        return "Mine Stage 6 not started"
                    case .goGetAxe:
                        return "Get an axe from the blacksmith"
                    case .collect:
                        return "Collect 100 lumber to upgrade the mine"
                    case .done:
                        return "Mine Stage 6 done"
                }
            case .mine7:
                return "Upgrade the mine!"
            case .mine8:
                return "Collect a gift from the Blacksmith"
            case .mine9:
                return "Mine 5 gold for the miner"
            case .mine10:
                switch Game.stages.mine.stage10Stages {
                    case .notStarted:
                        return "Mine Stage 10 not started"
                    case .goToSalesman:
                        return "Bring the coins back to the miner"
                    case .comeBack:
                        return "Return to the miner"
                    case .done:
                        return "Mine Stage 10 done"
                }
        }
    }
}
