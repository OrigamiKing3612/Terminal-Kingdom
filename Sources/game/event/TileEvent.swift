enum TileEvent: Codable {
    case openDoor(tile: DoorTile)
    case chopTree
    case startMining
    case talkToNPC(tile: NPCTile)
    //    case collectItem(item: String)
    //    case combat(enemy: String)
    
    static func trigger(event: TileEvent) {
        switch event {
            case .openDoor(tile: let doorTile):
                if MapBox.tilePlayerIsOn.type == .door(tile: doorTile) {
                    OpenDoorEvent.openDoor(doorTile: doorTile)
                }
            case .chopTree:
                if Game.player.has(item: .axe) {
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
        }
    }
}

enum DoorStages: Codable {
    case no, inProgress, done
}
