struct OpenDoorEvent {
    static func openDoor(doorTile: DoorTile) {
        if MapBox.mapType != .map && MapBox.mapType != .mining {
            MapBox.mapType = .map
        } else {
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
    }
}
