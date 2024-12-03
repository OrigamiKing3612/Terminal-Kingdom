struct SalesmanNPC {
    static func talk() {
        let tile = MapBox.tilePlayerIsOn
        if case .shopStandingArea(type: let type) = tile.type {
            switch type {
                case .buy:
                    if Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanBuy == false {
                        Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanBuy = true
                    }
                    buy()
                case .sell:
                    if Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanSell == false {
                        Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanSell = true
                    }
                    sell()
                case .help:
                    if Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanHelp == false {
                        Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanHelp = true
                    }
                    help()
            }
        }
    }
    private static func buyItem(item: Item, count: Int, price: Int) {
        if Game.player.has(item: .coin, count: price) {
            Game.player.collect(item: item, count: count)
            Game.player.remove(item: .coin, count: price)
        }
    }
    private static func addOptionsForSkill(options: inout [MessageOption], skillLevel: AllSkillLevels) {
        switch (skillLevel, skillLevel.stat) {
            case (.miningSkillLevel, .one):
                options.append(.init(label: "Pickaxe (50); price 10 coins", action: { buyItem(item: .pickaxe(durability: 50), count: 1, price: 10) }))
                options.append(.init(label: "Stone; price 2 coins", action: { buyItem(item: .stone, count: 1, price: 2) }))
                //TODO: press on item, and see a buy 1, buy 2...
                //TODO: Add more stuff here
            default:
                break
        }
    }
    private static func buy() {
        var leaveShop = false
        var options: [MessageOption] = [
            .init(label: "Leave", action: {leaveShop = true})
        ]
        for skillLevel in AllSkillLevels.allCases {
            addOptionsForSkill(options: &options, skillLevel: skillLevel)
        }
        if options.count <= 1 {
            MessageBox.message("There are no items are available to buy right now. Come back when you have more skills.", speaker: .salesman(type: .buy))
            return
        }
        while !leaveShop {
            let selectedOption = MessageBox.messageWithOptions("Would you like to buy?", speaker: .salesman(type: .buy), options: options)
            selectedOption.action()
        }
    }
    private static func sell() {
        //TODO: sell from shop
        MessageBox.message("Sell", speaker: .salesman(type: .sell))
    }
    private static func help() {
        MessageBox.message("Welcome to the shop \(Game.player.name)!", speaker: .salesman(type: .help))
        MessageBox.message("If you want to buy, talk to the guy with the \("!".styled(with: [.green, .blue])). Or if you want to sell talk to the guy with the \("!".styled(with: [.bold, .blue])).", speaker: .salesman(type: .help))
        Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanBuy = false
        Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanSell = false
    }
}
