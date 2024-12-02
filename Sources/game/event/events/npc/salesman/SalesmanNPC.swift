struct SalesmanNPC {
    static func talk() {
        if Game.startingVillageChecks.firstTimes.hasTalkedToSalesman == false {
            Game.startingVillageChecks.firstTimes.hasTalkedToSalesman = true
        }
        let tile = MapBox.tilePlayerIsOn
        if case .shopStandingArea(type: let type) = tile.type {
            switch type {
                case .buy:
                    buy()
                case .sell:
                    sell()
                case .help:
                    help()
            }
        }
    }
    private static func buy() {
        //TODO: buy from shop
        MessageBox.message("Buy", speaker: .salesman)
    }
    private static func sell() {
        //TODO: sell from shop
        MessageBox.message("Sell", speaker: .salesman)
    }
    private static func help() {
        //TODO: help from shop
        MessageBox.message("Help", speaker: .salesman)
    }
}
