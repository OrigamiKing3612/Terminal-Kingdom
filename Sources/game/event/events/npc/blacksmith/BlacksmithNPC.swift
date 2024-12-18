struct BlacksmithNPC {
    static func talk() {
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
            if Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith == false {
                Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith = true
                Game.stages.blacksmith.next()
                let options: [MessageOption] = [
                    .init(label: "Yes", action: {}),
                    .init(label: "No", action: {}),
                ]
                let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to be a blacksmith?", speaker: .blacksmith, options: options)
                if selectedOption.label != "Yes" {
                    return
                }
            }
            getStage()
        }
    }

    static func getStage() {
       switch Game.stages.blacksmith.stageNumber {
           case 1:
               stage1()
           default:
               break
       }
    }

    static func stage1() {
        Game.stages.blacksmith.stage = .inProgress
        switch Game.stages.blacksmith.stage1Stages {
            case .notStarted, .goToMine:
                Game.stages.blacksmith.stage1Stages = .goToMine
                MessageBox.message("I need you to go get some iron from the mine. Then bring it back to me. The door to the mine will be a \"\(DoorTile.renderDoor(tile: .init(type: .mine)))\" to help you find your way.", speaker: .blacksmith)
                StatusBox.quest(.blacksmith1)
            case .bringItBack:
                if Game.player.has(item: .iron, count: 1) {
                    MessageBox.message("Thank you!", speaker: .blacksmith)
                    Game.stages.blacksmith.next()
                    Game.stages.blacksmith.stage = .done
                    if let ironUUID = Game.stages.blacksmith.stage1AIronUUIDToRemove {
                        Game.player.removeItem(id: ironUUID)
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
}
