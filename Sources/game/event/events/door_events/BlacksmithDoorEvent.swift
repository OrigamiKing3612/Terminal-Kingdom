struct BlacksmithDoorEvent {
    
    static func open(tile: DoorTile) {
        var options: [MessageOption] = [
            .init(label: "Go Inside", action: { goInside(tile: tile) }),
        ]
        if tile.isPartOfPlayerVillage {
            options.append(.init(label: "Upgrade", action: { upgrade(tile: tile) }))
        }
        options.append(.init(label: "Quit", action: {}))
        let selectedOption = MessageBox.messageWithOptions("What would you like to do?", speaker: .game, options: options)
        selectedOption.action()
    }
    static func goInside(tile: DoorTile) {
        //TODO: Map changed to be a "map" of the building
        MessageBox.message("You go inside the door. You walk up to the blacksmith. You say hello.", speaker: .game)
        if Game.stages.blacksmith.stageNumber == 0 {
            let options: [MessageOption] = [
                .init(label: "Yes", action: {}),
                .init(label: "No", action: {})
            ]
            let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to be a blacksmith?", speaker: .blacksmith, options: options)
            if selectedOption.label == "Yes" {
                stage1(tile: tile)
            } else {
                return
            }
        } else if Game.stages.blacksmith.stageNumber == 1 {
            stage1(tile: tile)
        }
    }
    
    static func stage1(tile: DoorTile) {
        Game.stages.blacksmith.stage = .inProgress
        Game.stages.blacksmith.stageNumber = 1
        switch Game.stages.blacksmith.stage1Stages {
            case .notStarted, .goToMine:
                Game.stages.blacksmith.stage1Stages = .goToMine
                MessageBox.message("I need you to go get some iron from the mine. Then bring it back to me. The door to the mine will be a \"\(DoorTile.renderDoor(tile: .init(type: .mine)))\" to help you find your way.", speaker: .blacksmith)
                StatusBox.quest(.blacksmith1)
            case .bringItBack:
                if Game.player.has(item: .iron, count: 1) {
                    MessageBox.message("Thank you!", speaker: .blacksmith)
                    Game.stages.blacksmith.stageNumber = 2
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
    static func upgrade(tile: DoorTile) {
        //TODO: upgrade building
    }
}

enum BlacksmithStage1Stages: Codable {
    case notStarted, goToMine, bringItBack, done
}
