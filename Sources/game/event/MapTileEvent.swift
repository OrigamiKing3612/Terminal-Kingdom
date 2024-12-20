enum MapTileEvent: TileEvent {
    case openDoor(tile: DoorTile)
    case chopTree
    case startMining
    case talkToNPC(tile: NPCTile)
    case collectCrop
    case useStation(station: StationTile)
    //    case collectItem(item: String)
    //    case combat(enemy: String)

    static func trigger(event: MapTileEvent) {
        switch event {
            case .openDoor(tile: let doorTile):
                if MapBox.tilePlayerIsOn.type == .door(tile: doorTile) {
                    OpenDoorEvent.openDoor(doorTile: doorTile)
                }
            case .chopTree:
                if Game.player.hasAxe() {
                    ChopTreeEvent.chopTree()
                } else {
                    MessageBox.message("Ouch!", speaker: .game)
                }
            case .startMining:
                if Game.player.hasPickaxe() {
                    StartMiningEvent.startMining()
                } else {
                    MessageBox.message("You need a pickaxe to start mining", speaker: .miner)
                }
            case .talkToNPC(tile: let tile):
                tile.talk()
            case .collectCrop:
                let tile = MapBox.tilePlayerIsOn
                if case .crop(crop: let crop) = tile.type {
                    CollectCropEvent.collectCrop(cropTile: crop)
                } else if case .pot(tile: let tile) = tile.type {
                    if let cropTile = tile.cropTile {
                        CollectCropEvent.collectCrop(cropTile: cropTile)
                    } else {
                        MessageBox.message("There is no crop here", speaker: .game)
                    }
                }
            case .useStation(station: let station):
                UseStationEvent.useStation(tile: station)
        }
    }
    var name: String {
        switch self {
            case .openDoor(let tile):
                return "openDoor(\(tile.type.name))"
            case .chopTree:
                return "chopTree"
            case .startMining:
                return "startMining"
            case .talkToNPC(let tile):
                return "talkToNPC(\(tile.type.render))"
            case .collectCrop:
                return "collectCrop"
            case .useStation(station: let station):
                return "useStation(\(station.type.render))"
        }
    }
}
