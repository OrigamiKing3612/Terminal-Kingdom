struct MineDoorEvent {
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
        MapBox.mapType = .mine
    }
    
    static func upgrade(tile: DoorTile) {
        //TODO: upgrade building
    }
}

enum MineStage1Stages: Codable {
    case notStarted, collect, bringBack, done
}

enum MineStage2Stages: Codable {
    case notStarted, mine, done
}

