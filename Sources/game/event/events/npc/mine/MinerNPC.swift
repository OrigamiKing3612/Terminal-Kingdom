struct MinerNPC {
    static func talk() {
        if !Game.startingVillageChecks.firstTimes.hasTalkedToMiner {
            Game.startingVillageChecks.firstTimes.hasTalkedToMiner = true
        }
        if Game.stages.blacksmith.stage1Stages == .goToMine {
            MessageBox.message("Ah, here you are. This is the iron the \("Blacksmith".styled(with: .bold)) needs.", speaker: .miner)
            Game.stages.blacksmith.stage1Stages = .bringItBack
            Game.player.collect(item: .iron)
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
                MessageBox.message("I need you to mine 20 stone. You can do this by mining. The mine entrance the 'M' above and below me. is Here is a pickaxe. Be careful, it can only be used 50 times. ", speaker: .miner)
                StatusBox.quest(.mine2)
                //TODO: make a door in the mine to come back
                MessageBox.message("Oh also, press '\("l".styled(with: .bold))' to leave the mine.", speaker: .miner)
                Game.player.collect(item: .pickaxe())
                Game.stages.mine.stage2Stages = .mine
            case .mine:
                if Game.player.has(item: .stone, count: 20) {
                    MessageBox.message("Yay thank you! You have collected enough stone.", speaker: .miner)
                    Game.player.stats.miningSkillLevel = .one
                    Game.player.remove(item: .stone, count: 20)
                    StatusBox.removeQuest(quest: .mine1)
                    Game.stages.mine.stage2Stages = .done
                } else {
                    if !Game.player.hasPickaxe() {
                        MessageBox.message("Uh oh, looks like you lost your pickaxe, here is a new one.", speaker: .miner)
                        Game.player.collect(item: .pickaxe())
                    }
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .stone) - 20)) stone.", speaker: .miner)
                }
                fallthrough
            case .done:
                Game.stages.mine.next()
                if RandomEventStuff.wantsToContinue(speaker: .miner) {
                    getStage()
                }
        }
    }
}
