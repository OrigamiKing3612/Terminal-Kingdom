struct BlacksmithNPC {
    static func talk() {
        if Game.stages.mine.stage1Stages == .collect {
            MessageBox.message("Ah, here you are. Here is your pickaxe.", speaker: .blacksmith)
            Game.player.collect(item: .pickaxe(durability: 50))
            Game.stages.mine.stage1Stages = .bringBack
        } else if Game.stages.mine.stage4Stages == .collectPickaxe {
            MessageBox.message("Here you are. Here is your pickaxe.", speaker: .blacksmith)
            Game.player.collect(item: .pickaxe(durability: 50))
            Game.stages.mine.stage4Stages = .mine
        } else {
            if Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith == false {
                Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith = true
            }
            if Game.stages.blacksmith.stageNumber == 0 {
                let options: [MessageOption] = [
                    .init(label: "Yes", action: {}),
                    .init(label: "No", action: {}),
                ]
                let selectedOption = MessageBox.messageWithOptions(
                    "Hello \(Game.player.name)! Would you like to learn how to be a blacksmith?",
                    speaker: .blacksmith, options: options)
                if selectedOption.label == "Yes" {
                    stage1()
                } else {
                    return
                }
            } else if Game.stages.blacksmith.stageNumber == 1 {
                stage1()
            }
        }
    }
    
    static func getStage() {
        //TODO: Get stage
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
                    Game.player.remove(item: .iron)
                    StatusBox.removeQuest(quest: .blacksmith1)
                    MessageBox.message("WHAT SHOULD I DO AFTER THIS?", speaker: .game)
                } else {
                    MessageBox.message("Somehow do don't have iron.", speaker: .blacksmith)
                }
                Game.stages.blacksmith.stage1Stages = .done
            case .done:
                break
        }
    }
}
