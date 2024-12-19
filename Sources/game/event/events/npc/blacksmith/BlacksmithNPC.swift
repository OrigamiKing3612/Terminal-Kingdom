struct BlacksmithNPC {
    static func talk() {
        if Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith == false {
            Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith = true
        }
        if Game.stages.mine.stage1Stages == .collect {
            MessageBox.message("Ah, here you are. Here is your pickaxe.", speaker: .blacksmith)
            Game.stages.mine.stage1PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
            Game.stages.mine.stage1Stages = .bringBack
        } else if Game.stages.mine.stage4Stages == .collectPickaxe {
            MessageBox.message("Here you are. Here is your pickaxe.", speaker: .blacksmith)
            Game.stages.mine.stage4PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
            Game.stages.mine.stage4Stages = .mine
        } else if Game.stages.mine.stage6Stages == .goGetAxe {
            MessageBox.message("Here you are. Here is your axe.", speaker: .blacksmith)
            Game.stages.mine.stage6AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init(durability: 100)), canBeSold: false))
            Game.stages.mine.stage6Stages = .collect
        } else if Game.stages.mine.stage8Stages == .getPickaxe {
            MessageBox.message("Here you are. Here is your gift.", speaker: .blacksmith)
            Game.stages.mine.stage8PickaxeUUID = Game.player.collect(item: .init(type: .pickaxe(type: .init(durability: 1_000)), canBeSold: true))
        } else {
            getStage()
        }
    }

    static func getStage() {
        switch Game.stages.blacksmith.stageNumber {
            case 0:
                let options: [MessageOption] = [
                    .init(label: "Yes", action: {}),
                    .init(label: "No", action: {}),
                ]
                let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to be a blacksmith?", speaker: .blacksmith, options: options)
                if selectedOption.label == "Yes" {
                    Game.stages.blacksmith.next()
                    getStage()
                } else {
                    return
                }
            case 1:
                stage1()
            case 2:
                stage2()
            default:
                break
        }
    }

    static func stage1() {
        switch Game.stages.blacksmith.stage1Stages {
            case .notStarted, .goToMine:
                Game.stages.blacksmith.stage1Stages = .goToMine
                MessageBox.message("I need you to go get some iron from the mine. Then bring it back to me. The door to the mine will be a \"\("!".styled(with: [.red, .bold]))\" to help you find your way.", speaker: .blacksmith)
                StatusBox.quest(.blacksmith1)
            case .bringItBack:
                if Game.player.has(item: .iron, count: 5) {
                    MessageBox.message("Thank you!", speaker: .blacksmith)
                    if let ironUUID = Game.stages.blacksmith.stage1AIronUUIDsToRemove {
                        Game.player.removeItems(ids: ironUUID)
                    }
                    StatusBox.removeQuest(quest: .blacksmith1)
                    Game.stages.blacksmith.stage1Stages = .done
                    fallthrough
                } else {
                    MessageBox.message("Somehow do don't have iron.", speaker: .blacksmith)
                }
            case .done:
                Game.stages.blacksmith.next()
                if RandomEventStuff.wantsToContinue(speaker: .blacksmith) {
                    getStage()
                }
        }
    }
    static func stage2() {
        switch Game.stages.blacksmith.stage2Stages {
            case .notStarted:
                Game.stages.blacksmith.stage2Stages = .getLumber
                MessageBox.message("Now I need you to get 20 lumber. Here is an axe.", speaker: .blacksmith)
                Game.stages.blacksmith.stage2AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init(durability: 100)), canBeSold: false))
                StatusBox.quest(.blacksmith2)
            case .getLumber:
                if Game.player.has(item: .lumber, count: 20) {
                    MessageBox.message("Thank you!", speaker: .blacksmith)
                    if let id  = Game.stages.blacksmith.stage2AxeUUIDToRemove {
                        Game.player.removeItem(id: id)
                    }
                    Game.player.removeItem(item: .lumber, count: 20)
                    StatusBox.removeQuest(quest: .blacksmith2)
                    Game.stages.blacksmith.stage2Stages = .done
                    fallthrough
                } else {
                    if let stage2AxeUUIDToRemove = Game.stages.blacksmith.stage2AxeUUIDToRemove, !Game.player.has(id: stage2AxeUUIDToRemove) {
                        MessageBox.message("Uh oh, looks like you lost your axe, here is a new one.", speaker: .blacksmith)
                        Game.stages.blacksmith.stage2AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
                    }
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .clay) - 20)) clay.", speaker: .blacksmith)
                }
            case .done:
                Game.stages.blacksmith.next()
                if RandomEventStuff.wantsToContinue(speaker: .blacksmith) {
                    getStage()
                }
        }
    }
}

enum BlacksmithStage1Stages: Codable {
    case notStarted, goToMine, bringItBack, done
}

enum BlacksmithStage2Stages: Codable {
    case notStarted, getLumber, done
}
