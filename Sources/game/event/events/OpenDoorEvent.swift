struct OpenDoorEvent {
    static func openDoor(doorTile: DoorTile) {
        switch doorTile.type {
            case .castle: CastleDoorEvent.open(tile: doorTile)
            case .blacksmith: BlacksmithDoorEvent.open(tile: doorTile)
            case .mine: MineDoorEvent.open(tile: doorTile)
            case .shop: ShopDoorEvent.open(tile: doorTile)
            case .builder: BuilderDoorEvent.open(tile: doorTile)
            case .hunting_area: HuntingAreaDoorEvent.open(tile: doorTile)
            case .inventor: InventorDoorEvent.open(tile: doorTile)
            case .house: HouseDoorEvent.open(tile: doorTile)
            case .stable: StableDoorEvent.open(tile: doorTile)
            case .farm: FarmDoorEvent.open(tile: doorTile)
            case .hospital: HospitalDoorEvent.open(tile: doorTile)
            case .carpenter: CarpenterDoorEvent.open(tile: doorTile)
            case .restaurant: RestaurantDoorEvent.open(tile: doorTile)
            case .potter: PotterAreaDoorEvent.open(tile: doorTile)
        }
    }
    static func teachToChopLumber(by choppingLumberTeachingDoorTypes: ChoppingLumberTeachingDoorTypes) {
        let speaker: MessageSpeakers = switch choppingLumberTeachingDoorTypes {
            case .builder: .builder
            case .carpenter: .carpenter
            case .miner: .miner
        }
        //TODO: switch statement
        switch Game.startingVillageChecks.hasBeenTaughtToChopLumber {
            case .no:
                MessageBox.message("Here is what you need to do, take this axe and walk up to a tree and press the '\("i".styled(with: .bold))' key, the \("spacebar".styled(with: .bold)), or the \("enter".styled(with: .bold)) key to chop it down. Please go get 10 lumber and bring it to me to show me you can do it.", speaker: speaker)
                Game.player.collectIfNotPresent(item: .axe)
                StatusBox.quest(.chopLumber(count: 10, for: choppingLumberTeachingDoorTypes.name))
                Game.startingVillageChecks.hasBeenTaughtToChopLumber = .inProgress(by: choppingLumberTeachingDoorTypes)
            case .inProgress(by: choppingLumberTeachingDoorTypes):
                if Game.player.has(item: .lumber, count: 10) {
                    MessageBox.message("Nice! 10 lumber! Now we can continue.", speaker: speaker)
                    Game.player.remove(item: .lumber, count: 10)
                    Game.player.remove(item: .axe)
                    Game.startingVillageChecks.hasBeenTaughtToChopLumber = .yes
                    StatusBox.removeQuest(quest: .chopLumber(count: 10, for: choppingLumberTeachingDoorTypes.name))
                } else {
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .lumber) - 10)) lumber.", speaker: speaker)
                }
            default:
                if case .inProgress(let otherDoorType) = Game.startingVillageChecks.hasBeenTaughtToChopLumber {
                    MessageBox.message("Please finish \(otherDoorType.name)'s quest first, then come back here.", speaker: speaker)
                }
        }
    }
}
