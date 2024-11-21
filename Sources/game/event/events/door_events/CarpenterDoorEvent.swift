struct CarpenterDoorEvent {
    nonisolated(unsafe) static var stage: Int = 0
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
        MessageBox.message("You go inside the door. You walk up to the carpenter. You say hello.", speaker: .game)
        
        if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
            let options: [MessageOption] = [
                .init(label: "Yes", action: { goInside(tile: tile) }),
                .init(label: "No", action: { })
            ]
            let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn carpentry?", speaker: .carpenter, options: options)
            if selectedOption.label == "Yes" {
                stage0()
            } else {
                return
            }
        } else {
            stage0()
        }
    }
    static func stage0() {
        if Game.startingVillageChecks.hasBeenTaughtToChopLumber != .yes {
            if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
                MessageBox.message("Before I can teach you carpentry, you need to learn how to chop lumber.", speaker: .carpenter)
            }
            OpenDoorEvent.teachToChopLumber(by: .carpenter)
            if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .yes {
                stage1()
            }
        } else {
            MessageBox.message("Looks like you already know how to chop lumber. Lets start.", speaker: .carpenter)
            stage1()
        }
    }
    static func stage1() {
        MessageBox.message("I need you to....", speaker: .carpenter)
    }
    static func upgrade(tile: DoorTile) {
        //TODO: upgrade building
    }
}
