struct MinerNPC {
    static func talk() {
        if !Game.startingVillageChecks.firstTimes.hasTalkedToMiner {
            Game.startingVillageChecks.firstTimes.hasTalkedToMiner = true
        }
        if Game.stages.blacksmith.stage1Stages == .goToMine {
            MessageBox.message("Ah, here you are. This is the iron the \("Blacksmith".styled(with: .bold)) needs.", speaker: .miner)
            Game.stages.blacksmith.stage1Stages = .bringItBack
            Game.stages.blacksmith.stage1AIronUUIDsToRemove = Game.player.collect(item: .init(type: .iron, canBeSold: false), count: 5)
        } else if Game.stages.blacksmith.stage4Stages == .collect {
            MessageBox.message("Yes let me get that for you.", speaker: .miner)
            Game.stages.blacksmith.stage4Stages = .bringItBack
            Game.stages.blacksmith.stage4CoalUUIDsToRemove = Game.player.collect(item: .init(type: .coal, canBeSold: false), count: 5)
        } else if Game.stages.blacksmith.stage8Stages == .getMaterials {
            MessageBox.message("Yes let me get that for you.", speaker: .miner)
            let uuids1 = Game.player.collect(item: .init(type: .iron, canBeSold: false), count: 3)
            let uuids2 = Game.player.collect(item: .init(type: .coal, canBeSold: false), count: 3)
            Game.stages.blacksmith.stage8MaterialsToRemove = uuids1 + uuids2
            Game.stages.blacksmith.stage8Stages = .makeSteel
        } else {
            getStage()
        }
    }

    static func getStage() {
        if Game.stages.mine.isDone {
            MessageBox.message("Thank you for helping me. You have completed all of the tasks I have for you.", speaker: .miner)
        } else {
            switch Game.stages.mine.stageNumber {
                case 0:
                    if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
                        let options: [MessageOption] = [
                            .init(label: "Yes", action: {}),
                            .init(label: "No", action: {}),
                        ]
                        let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to mine?", speaker: .miner, options: options)
                        if selectedOption.label == "Yes" {
                            stage0()
                        } else {
                            return
                        }
                    } else {
                        stage0()
                    }
                case 1:
                    stage1()
                case 2:
                    stage2()
                case 3:
                    stage3()
                case 4:
                    stage4()
                case 5:
                    stage5()
                case 6:
                    stage6()
                case 7:
                    stage7()
                case 8:
                    stage8()
                case 9:
                    stage9()
                case 10:
                    stage10()
                default:
                    break
            }
        }
    }

    static func stage0() {
        if Game.startingVillageChecks.hasBeenTaughtToChopLumber != .yes {
            if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
                MessageBox.message("Before I can teach you how to mine, you need to learn how to chop lumber.", speaker: .miner)
            }
            RandomEventStuff.teachToChopLumber(by: .miner)
            if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .yes {
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    stage1()
                }
            }
        } else {
            MessageBox.message("Hello \(Game.player.name)! Looks like you already know how to chop lumber.", speaker: .miner)
            let options: [MessageOption] = [
                .init(label: "Yes", action: {}),
                .init(label: "No", action: {}),
            ]
            let selectedOption = MessageBox.messageWithOptions("Would you like to learn how to mine?", speaker: .miner, options: options)
            if selectedOption.label == "Yes" {
                stage1()
            }
        }
    }
    static func stage1() {
        switch Game.stages.mine.stage1Stages {
            case .notStarted:
                MessageBox.message("To mine, you need a pickaxe. Go get one from the \("Blacksmith".styled(with: .bold)), he will have one for you.", speaker: .miner)
                StatusBox.quest(.mine1)
                Game.stages.mine.stage1Stages = .collect
            case .collect:
                MessageBox.message("It doesn't look like you got a pickaxe. from the \("Blacksmith".styled(with: .bold)). His building it marked with an \("!".styled(with: [.bold, .red]))", speaker: .miner)
            case .bringBack:
                MessageBox.message("Thank you for getting the pickaxe!", speaker: .miner)
                Game.stages.mine.stage1Stages = .done
                if let id = Game.stages.mine.stage1PickaxeUUIDToRemove {
                    Game.player.removeItem(id: id)
                }
                StatusBox.removeQuest(quest: .mine1)
                fallthrough
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
    static func stage2() {
        switch Game.stages.mine.stage2Stages {
            case .notStarted:
                //TODO: make the Mine ! (red bold) (this is already the first time so no check needed)
                MessageBox.message("I need you to mine 20 clay. You can do this by mining. The mine entrance the 'M' above and below me. is Here is a pickaxe. Be careful, it can only be used 50 times. ", speaker: .miner)
                StatusBox.quest(.mine2)
                //TODO: make a door in the mine to come back
                MessageBox.message("Oh also, press '\("l".styled(with: .bold))' to leave the mine.", speaker: .miner)
                Game.stages.mine.stage2PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
                Game.stages.mine.stage2Stages = .mine
            case .mine:
                if Game.player.has(item: .clay, count: 20) {
                    MessageBox.message("Yay thank you! You have collected enough clay.", speaker: .miner)
                    Game.player.stats.miningSkillLevel = .one
                    Game.player.removeItem(item: .clay, count: 20)
                    StatusBox.removeQuest(quest: .mine1)
                    Game.stages.mine.stage2Stages = .done
                    if let id = Game.stages.mine.stage2PickaxeUUIDToRemove {
                        Game.player.removeItem(id: id)
                    }
                    StatusBox.removeQuest(quest: .mine2)
                    fallthrough
                } else {
                    if let stage2AxeUUIDToRemove = Game.stages.mine.stage2PickaxeUUIDToRemove, !Game.player.has(id: stage2AxeUUIDToRemove) {
                        MessageBox.message("Uh oh, looks like you lost your pickaxe, here is a new one.", speaker: .miner)
                        Game.stages.mine.stage2PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
                    }
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .clay) - 20)) clay.", speaker: .miner)
                }
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
    static func stage3() {
        switch Game.stages.mine.stage3Stages {
            case .notStarted:
                MessageBox.message("We need 50 lumber to upgrade the mine to be able to mine more stuff. Can you please go get 50 lumber and bring it back to me?", speaker: .miner)
                Game.stages.mine.stage3AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
                StatusBox.quest(.mine3)
                Game.stages.mine.stage3Stages = .collect
            case .collect:
                if Game.player.has(item: .lumber, count: 50) {
                    MessageBox.message("Thank you for getting the lumber! Now we can upgrade the mine.", speaker: .miner)
                    Game.player.removeItem(item: .lumber, count: 50)
                    if let id = Game.stages.mine.stage3AxeUUIDToRemove {
                        Game.player.removeItem(id: id)
                    }
                    Game.player.stats.mineLevel = .two
                    Game.stages.mine.stage3Stages = .done
                    Game.player.stats.miningSkillLevel = .two
                    StatusBox.removeQuest(quest: .mine3)
                    fallthrough
                } else {
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .lumber) - 50)) lumber.", speaker: .miner)
                }
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
    static func stage4() {
        switch Game.stages.mine.stage4Stages {
            case .notStarted:
                MessageBox.message("Now that we have upgraded the mine, you can go to level 2! There you can find things like stone, coal, and iron.", speaker: .miner)
                MessageBox.message("I need you to get a pickaxe from the \("Blacksmith".styled(with: .bold)). Then go get 30 stone for me.", speaker: .miner)
                StatusBox.quest(.mine4)
                Game.stages.mine.stage4Stages = .collectPickaxe
            case .collectPickaxe:
                MessageBox.message("It doesn't look like you got a pickaxe. from the \("Blacksmith".styled(with: .bold)). His building it marked with an \("!".styled(with: [.bold, .red]))", speaker: .miner)
            case .mine:
                if Game.player.has(item: .stone, count: 30) {
                    MessageBox.message("Thank you for getting the stone!", speaker: .miner)
                    Game.player.removeItem(item: .stone, count: 30)
                    if let id = Game.stages.mine.stage4PickaxeUUIDToRemove {
                        Game.player.removeItem(id: id)
                    }
                    Game.stages.mine.stage4Stages = .done
                    Game.player.stats.miningSkillLevel = .three
                    StatusBox.removeQuest(quest: .mine4)
                    fallthrough
                } else {
                    if !Game.player.hasPickaxe() {
                        MessageBox.message("Uh oh, looks like you lost your pickaxe, here is a new one.", speaker: .miner)
                        Game.stages.mine.stage4PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
                    }
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .stone) - 30)) stone from level 2 of the mine.", speaker: .miner)
                }
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
    static func stage5() {
        switch Game.stages.mine.stage5Stages {
            case .notStarted:
                MessageBox.message("Here is another pickaxe. I need you to go get 20 iron for me.", speaker: .miner)
                StatusBox.quest(.mine5)
                Game.stages.mine.stage5Stages = .mine
                Game.stages.mine.stage5PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
            case .mine:
                if Game.player.has(item: .iron, count: 20) {
                    MessageBox.message("Thank you for getting the iron!", speaker: .miner)
                    Game.player.removeItem(item: .iron, count: 20)
                    if let id = Game.stages.mine.stage5PickaxeUUIDToRemove {
                        Game.player.removeItem(id: id)
                    }
                    Game.stages.mine.stage5Stages = .done
                    Game.player.stats.miningSkillLevel = .four
                    StatusBox.removeQuest(quest: .mine5)
                    fallthrough
                } else {
                    if !Game.player.hasPickaxe() {
                        MessageBox.message("Uh oh, looks like you lost your pickaxe, here is a new one.", speaker: .miner)
                        Game.stages.mine.stage5PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
                    }
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .iron) - 20)) iron.", speaker: .miner)
                }
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
    static func stage6() {
        switch Game.stages.mine.stage6Stages {
            case .notStarted:
                MessageBox.message("I haven't told you why you need to get all of this stuff yet. We are going to upgrade the mine again. Everytime the items required to do so increase. So this time we need 100 lumber to upgrade. You are almost there to being a professional miner!", speaker: .miner)
                MessageBox.message("Oh, also, I don't have an axe for you. The \("Blacksmith".styled(with: .bold)) can give you one.", speaker: .miner)
                StatusBox.quest(.mine6)
                Game.stages.mine.stage6Stages = .goGetAxe
            case .goGetAxe:
                MessageBox.message("I don't have an axe for you. The \("Blacksmith".styled(with: .bold)) can give you one.", speaker: .miner)
            case .collect:
                if Game.player.has(item: .lumber, count: 100) {
                    MessageBox.message("Thank you for getting the lumber!", speaker: .miner)
                    Game.player.removeItem(item: .lumber, count: 100)
                    if let id = Game.stages.mine.stage6AxeUUIDToRemove {
                        Game.player.removeItem(id: id)
                    }
                    Game.stages.mine.stage6Stages = .done
                    Game.player.stats.miningSkillLevel = .five
                    StatusBox.removeQuest(quest: .mine6)
                    fallthrough
                } else {
                    if !Game.player.hasPickaxe() {
                        MessageBox.message("Uh oh, looks like you lost your pickaxe, here is a new one.", speaker: .miner)
                        Game.stages.mine.stage6AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
                    }
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .lumber) - 100)) lumber.", speaker: .miner)
                }
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
    static func stage7() {
        switch Game.stages.mine.stage7Stages {
            case .notStarted:
                MessageBox.message("Ok, now that we have the suppilies, we can upgrade the mine. This time I will let you do it! All you have to do is have the materials and go up to the door. There will be an option to upgrade, do that! Then come back to me.", speaker: .miner)
                StatusBox.quest(.mine7)
                let uuids1 = Game.player.collect(item: Item(type: .stone, canBeSold: false), count: 30)
                let uuids2 = Game.player.collect(item: Item(type: .iron, canBeSold: false), count: 20)
                let uuids3 = Game.player.collect(item: Item(type: .lumber, canBeSold: false), count: 100)

                Game.stages.mine.stage7ItemUUIDsToRemove = uuids1 + uuids2 + uuids3
                Game.stages.mine.stage7Stages = .upgrade
            case .upgrade:
                MessageBox.message("You haven't upgraded the mine yet. You need to walk up to the door and select upgrade.", speaker: .miner)
            case .upgraded:
                MessageBox.message("Now that you have upgraded the mine, you can go to level 3! There you can find gold.", speaker: .miner)
                Game.stages.mine.stage7Stages = .done
                Game.player.stats.miningSkillLevel = .seven
                Game.player.stats.mineLevel = .three
                StatusBox.removeQuest(quest: .mine7)
                fallthrough
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
    static func stage8() {
        switch Game.stages.mine.stage8Stages {
            case .notStarted:
                MessageBox.message("I asked the blacksmith to make a special gift for you. Go collect it from the blacksmith. Then come talk to me.", speaker: .miner)
                StatusBox.quest(.mine8)
                Game.stages.mine.stage8Stages = .getPickaxe
            case .getPickaxe:
                if let id = Game.stages.mine.stage8PickaxeUUID {
                    if Game.player.has(id: id) {
                        MessageBox.message("Thank you for getting the gift from the blacksmith! I hope you like it. It should help you in the future.", speaker: .miner)
                        Game.stages.mine.stage8Stages = .done
                        StatusBox.removeQuest(quest: .mine8)
                        fallthrough
                    } else {
                        MessageBox.message("You haven't gotten the gift from the blacksmith yet.", speaker: .miner)
                    }
                } else {
                    MessageBox.message("You haven't gotten the gift from the blacksmith yet.", speaker: .miner)
                }
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
    static func stage9() {
        switch Game.stages.mine.stage9Stages {
            case .notStarted:
                MessageBox.message("I want to teach you one more thing, but to do that I need to go get 5 gold from level 3 of the mine", speaker: .miner)
                StatusBox.quest(.mine9)
                Game.stages.mine.stage9Stages = .mine
            case .mine:
                if Game.player.has(item: .gold, count: 5) {
                    MessageBox.message("Thank you for getting the gold!", speaker: .miner)
                    Game.player.removeItem(item: .gold, count: 5)
                    Game.stages.mine.stage9Stages = .done
                    Game.player.stats.miningSkillLevel = .nine
                    if let id = Game.stages.mine.stage9PickaxeUUIDToRemove {
                        Game.player.removeItem(id: id)
                    }
                    StatusBox.removeQuest(quest: .mine9)
                    fallthrough
                } else {
                    if !Game.player.hasPickaxe() {
                        MessageBox.message("Uh oh, looks like you lost your pickaxe, here is a new one.", speaker: .miner)
                        Game.stages.mine.stage9PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
                    }
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .gold) - 5)) gold.", speaker: .miner)
                }
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
    static func stage10() {
        switch Game.stages.mine.stage10Stages {
            case .notStarted:
                MessageBox.message("I have one more thing for you to do. I need you to take this gold to the \("Salesman".styled(with: .bold)) and sell it for coins. Then come back to me.", speaker: .miner)
                StatusBox.quest(.mine10)
                Game.stages.mine.stage10Stages = .goToSalesman
                Game.stages.mine.stage10GoldUUIDsToRemove = Game.player.collect(item: .init(type: .gold, canBeSold: false), count: 5)
            case .goToSalesman:
                MessageBox.message("You haven't sold the gold to the \("Salesman".styled(with: .bold)) yet.", speaker: .miner)
            case .comeBack:
                MessageBox.message("Thank you for selling the gold to the \("Salesman".styled(with: .bold)). I want you to keep the coins! Thank you for being a good junior miner!", speaker: .miner)
                Game.stages.mine.stage10Stages = .done
                Game.player.stats.miningSkillLevel = .ten
                StatusBox.removeQuest(quest: .mine10)
                fallthrough
            case .done:
                Game.stages.mine.next()
        }
    }
}

enum MineStage1Stages: Codable {
    case notStarted, collect, bringBack, done
}

enum MineStage2Stages: Codable {
    case notStarted, mine, done
}

enum MineStage3Stages: Codable {
    case notStarted, collect, done
}

enum MineStage4Stages: Codable {
    case notStarted, collectPickaxe, mine, done
}

enum MineStage5Stages: Codable {
    case notStarted, mine, done
}

enum MineStage6Stages: Codable {
    case notStarted, goGetAxe, collect, done
}

enum MineStage7Stages: Codable {
    case notStarted, upgrade, upgraded, done
}

enum MineStage8Stages: Codable {
    case notStarted, getPickaxe, done
}

enum MineStage9Stages: Codable {
    case notStarted, mine, done
}

enum MineStage10Stages: Codable {
    case notStarted, goToSalesman, comeBack, done
}
