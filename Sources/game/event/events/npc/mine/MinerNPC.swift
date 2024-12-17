struct MinerNPC {
    static func talk() {
        if !Game.startingVillageChecks.firstTimes.hasTalkedToMiner {
            Game.startingVillageChecks.firstTimes.hasTalkedToMiner = true
        }
        if Game.stages.blacksmith.stage1Stages == .goToMine {
            MessageBox.message("Ah, here you are. This is the iron the \("Blacksmith".styled(with: .bold)) needs.", speaker: .miner)
            Game.stages.blacksmith.stage1Stages = .bringItBack
            Game.stages.blacksmith.stage1AIronUUIDToRemove = Game.player.collect(item: .init(type: .iron, canBeSold: false))
        } else {
            getStage()
        }
    }

    static func getStage() {
        switch Game.stages.mine.stageNumber {
            case 0:
                if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
                    let options: [MessageOption] = [
                        .init(label: "Yes", action: {}),
                        .init(label: "No", action: {}),
                    ]
                    let selectedOption = MessageBox.messageWithOptions(
                        "Hello \(Game.player.name)! Would you like to learn how to mine?",
                        speaker: .miner, options: options)
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
            default:
                break
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
            MessageBox.message("Looks like you already know how to chop lumber. Lets start.", speaker: .miner)
            stage1()
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
                Game.stages.mine.stage2PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(durability: 50), canBeSold: false))
                Game.stages.mine.stage2Stages = .mine
            case .mine:
                if Game.player.has(item: .clay, count: 20) {
                    MessageBox.message("Yay thank you! You have collected enough clay.", speaker: .miner)
                    Game.player.stats.miningSkillLevel = .one
                    Game.player.removeItem(item: .clay, count: 20)
                    StatusBox.removeQuest(quest: .mine1)
                    Game.stages.mine.stage2Stages = .done
                    StatusBox.removeQuest(quest: .mine2)
                    fallthrough
                } else {
                    if let stage2AxeUUIDToRemove = Game.stages.mine.stage2PickaxeUUIDToRemove, !Game.player.has(id: stage2AxeUUIDToRemove) {
                        MessageBox.message("Uh oh, looks like you lost your pickaxe, here is a new one.", speaker: .miner)
                        Game.stages.mine.stage2PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(durability: 50), canBeSold: false))
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
                Game.stages.mine.stage3AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe, canBeSold: false))
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
                MessageBox.message("I need you to get a pickaxe from the \("Blacksmith".styled(with: .bold)). Then go get 20 stone for me.", speaker: .miner)
                StatusBox.quest(.mine4)
                Game.stages.mine.stage4Stages = .collectPickaxe
            case .collectPickaxe:
                MessageBox.message("It doesn't look like you got a pickaxe. from the \("Blacksmith".styled(with: .bold)). His building it marked with an \("!".styled(with: [.bold, .red]))", speaker: .miner)
            case .mine:
                if Game.player.has(item: .stone, count: 20) {
                    MessageBox.message("Thank you for getting the stone!", speaker: .miner)
                    Game.player.removeItem(item: .stone, count: 20)
                    if let id = Game.stages.mine.stage4PickaxeUUIDToRemove {
                        Game.player.removeItem(id: id)
                    }
                    Game.stages.mine.stage4Stages = .done
                    Game.player.stats.miningSkillLevel = .three
                    StatusBox.removeQuest(quest: .mine4)
                    fallthrough
                } else {
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .stone) - 20)) stone from level 2 of the mine.", speaker: .miner)
                }
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
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
