struct FarmDoorEvent {
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
        MessageBox.message("You go inside the door. You walk up to the farmer. You say hello.", speaker: .game)
        
        let options: [MessageOption] = [
            .init(label: "Yes", action: { goInside(tile: tile) }),
            .init(label: "No", action: { })
        ]
        let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to be a farmer?", speaker: .farmer, options: options)
        if selectedOption.label == "Yes" {
            stage1()
        } else {
            return
        }
    }
    static func stage1() {
        
    }
    static func upgrade(tile: DoorTile) {
        //TODO: upgrade building
    }
}

enum FarmStage1Stages: Codable {
    case notStarted, mine, done
}
