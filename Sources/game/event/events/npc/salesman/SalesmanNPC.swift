struct SalesmanNPC {
    static func talk() {
        if Game.stages.mine.stage10Stages == .goToSalesman {
            MessageBox.message("Oooh 5 gold! Can buy that for 10 coins!", speaker: .salesman(type: .buy))
            let options: [MessageOption] = [
                .init(label: "Yes", action: {
                    if let ids = Game.stages.mine.stage10GoldUUIDsToRemove {
                        Game.player.removeItems(ids: ids)
                        _ = Game.player.collect(item: .init(type: .coin), count: 10)
                        MessageBox.message("Thank you!", speaker: .salesman(type: .buy))
                        Game.stages.mine.stage10Stages = .comeBack
                    }
                }),
                .init(label: "No", action: {
                    MessageBox.message("Oh ok", speaker: .salesman(type: .buy))
                })
            ]
            let selectedOption = MessageBox.messageWithOptions("Would you like to sell the 5 gold?", speaker: .salesman(type: .buy), options: options)
            selectedOption.action()
        } else if Game.stages.blacksmith.stage9Stages == .goToSalesman {
            let price = ItemType.steel.price! * 3
            MessageBox.message("Oooh 3 steel! Can buy that for \(price) coins!", speaker: .salesman(type: .buy))
            let options: [MessageOption] = [
                .init(label: "Yes", action: {
                    if let ids = Game.stages.blacksmith.stage9SteelUUIDToRemove {
                        Game.player.removeItems(ids: ids)
                        _ = Game.player.collect(item: .init(type: .coin), count: price)
                        MessageBox.message("Thank you!", speaker: .salesman(type: .buy))
                        Game.stages.blacksmith.stage9Stages = .comeBack
                    }
                }),
                .init(label: "No", action: {
                    MessageBox.message("Oh ok", speaker: .salesman(type: .buy))
                })
            ]
            let selectedOption = MessageBox.messageWithOptions("Would you like to sell the 3 steel?", speaker: .salesman(type: .buy), options: options)
            selectedOption.action()
        } else {
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
            let selectedOption = MessageBox.messageWithOptions("Would you like to buy?", speaker: .salesman(type: .buy), options: options, hideInventoryBox: false)
            if selectedOption.label != "Leave" {
                let amount = MessageBox.messageWithTypingNumbers("How many?", speaker: .salesman(type: .buy))
                for _ in 1...amount {
                    selectedOption.action()
                }
            } else {
                leaveShop = true
            }
        }
    }
    private static func sell() {
        var leaveShop = false
        var options: [MessageOption] = [
            .init(label: "Leave", action: {leaveShop = true})
        ]
        for item in Array(Set(Game.player.items)) {
            sellOption(options: &options, item: item)
        }
        while !leaveShop {
            let selectedOption = MessageBox.messageWithOptions("Would you like to sell?", speaker: .salesman(type: .sell), options: options, hideInventoryBox: false)
            if selectedOption.label != "Leave" {
                let amount = MessageBox.messageWithTypingNumbers("How many?", speaker: .salesman(type: .sell))
                for _ in 1...amount {
                    selectedOption.action()
                }
                InventoryBox.printInventory()
            } else {
                leaveShop = true
            }
        }
    }
    private static func help() {
        MessageBox.message("Welcome to the shop \(Game.player.name)!", speaker: .salesman(type: .help))
        MessageBox.message("If you want to buy, talk to the guy with the \("!".styled(with: [.green, .blue])). Or if you want to sell talk to the guy with the \("!".styled(with: [.bold, .blue])).", speaker: .salesman(type: .help))
        Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanBuy = false
        Game.startingVillageChecks.firstTimes.hasTalkedToSalesmanSell = false
    }
}

extension SalesmanNPC {
    private static func buyItem(item: ItemType, count: Int, price: Int) {
        if Game.player.has(item: .coin, count: price) {
            _ = Game.player.collect(item: .init(type: item), count: count)
            Game.player.removeItem(item: .coin, count: price * count)
        } else {
            MessageBox.message("You don't have enough coins!", speaker: .salesman(type: .buy))
        }
    }
    private static func sellItem(item: Item, count: Int, price: Int) {
        if Game.player.has(item: item, count: count) {
            Game.player.removeItem(item: item.type, count: count)
            _ = Game.player.collect(item: .init(type: .coin), count: price * count)
        } else {
            MessageBox.message("You don't have that much!", speaker: .salesman(type: .sell))
        }
    }
    private static func addOptionsForSkill(options: inout [MessageOption], skillLevel: AllSkillLevels) {
        if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .yes {
            buyOption(options: &options, item: .lumber)
        }
        switch (skillLevel, skillLevel.stat) {
            case (.miningSkillLevel, .one):
                buyOption(options: &options, item: .pickaxe(type: .init()))
                buyOption(options: &options, item: .stone)
                //TODO: press on item, and see a buy 1, buy 2, buy 5, buy 10...
                //TODO: Add more stuff here
            default:
                break
        }
    }
    private static func buyOption(options: inout [MessageOption], item: ItemType) {
        if let price = item.price {
            let newItem = MessageOption(label: "\(item.inventoryName); price: \(price) coin\(price > 1 ? "s" : "")", action: { buyItem(item: item, count: 1, price: price) })
            if !options.contains(where: { $0 != newItem}) {
                options.append(newItem)
            }
        }
    }
    private static func sellOption(options: inout [MessageOption], item: Item) {
        if let price = item.price, item.canBeSold {
            let newItem = MessageOption(label: "\(item.inventoryName); price: \(price) coins", action: { sellItem(item: item, count: 1, price: price) })
            if options.contains(where: { $0 != newItem}){
                options.append(newItem)
            }
        }
    }
}
