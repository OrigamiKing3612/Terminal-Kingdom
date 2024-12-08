struct OpenDoorEvent {
    static func openDoor(doorTile: DoorTile) {
        if MapBox.mapType != .mainMap && MapBox.mapType != .mining {
            leaveBuildingMap()
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
    private static func leaveBuildingMap() {
        let currentTile = MapBox.tilePlayerIsOn
        
        switch MapBox.mapType {
            case .farm(type: let farmType):
                if case .door(let playerDoorTile) = currentTile.type {
                    //enter, out
                    switch (farmType, playerDoorTile.type) {
                        case (.main, .farm(type: .farm_area)):
                            MapBox.mainMap.setPlayerPosition(DoorTileTypes.farm(type: .main).coordinatesForStartingVillageBuildings)
                        case (.farm_area, .farm(type: .main)):
                            MapBox.mainMap.setPlayerPosition(DoorTileTypes.farm(type: .farm_area).coordinatesForStartingVillageBuildings)
                        default:
                            //No change in doors has happened
                            break
                    }
                }
                
            case .castle(side: let castleSide):
                exitCastle(castleSide: castleSide, currentTile: currentTile)
            case .hospital(side: let hospitalSide):
                if case .door(let playerDoorTile) = currentTile.type {
                    //enter, out
                    switch (hospitalSide, playerDoorTile.type) {
                        case (.top, .hospital(side: .bottom)):
                            MapBox.mainMap.setPlayerPosition(DoorTileTypes.hospital(side: .bottom).coordinatesForStartingVillageBuildings)
                        case (.bottom, .hospital(side: .top)):
                            MapBox.mainMap.setPlayerPosition(DoorTileTypes.hospital(side: .top).coordinatesForStartingVillageBuildings)
                        default:
                            //No change in doors has happened
                            break
                    }
                }
            default:
                break
        }
        
        // Return to the main map
        MapBox.mapType = .mainMap
    }
    
    private static func exitCastle(castleSide: CastleSide, currentTile: MapTile) {
        var topCoordinates: Void {
            MapBox.mainMap.setPlayerPosition(DoorTileTypes.castle(side: .top).coordinatesForStartingVillageBuildings)
        }
        var rightCoordinates: Void {
            MapBox.mainMap.setPlayerPosition(DoorTileTypes.castle(side: .right).coordinatesForStartingVillageBuildings)
        }
        var bottomCoordinates: Void {
            MapBox.mainMap.setPlayerPosition(DoorTileTypes.castle(side: .bottom).coordinatesForStartingVillageBuildings)
        }
        var leftCoordinates: Void {
            MapBox.mainMap.setPlayerPosition(DoorTileTypes.castle(side: .left).coordinatesForStartingVillageBuildings)
        }
        if case .door(let playerDoorTile) = currentTile.type {
            //enter, out
            switch (castleSide, playerDoorTile.type) {
                case (.top, .castle(side: .right)):
                    rightCoordinates
                case (.top, .castle(side: .bottom)):
                    bottomCoordinates
                case (.top, .castle(side: .left)):
                    leftCoordinates
                    
                case (.right, .castle(side: .top)):
                    topCoordinates
                case (.right, .castle(side: .bottom)):
                    bottomCoordinates
                case (.right, .castle(side: .left)):
                    leftCoordinates
                    
                case (.bottom, .castle(side: .top)):
                    topCoordinates
                case (.bottom, .castle(side: .right)):
                    rightCoordinates
                case (.bottom, .castle(side: .left)):
                    leftCoordinates
                    
                case (.left, .castle(side: .top)):
                    topCoordinates
                case (.left, .castle(side: .right)):
                    rightCoordinates
                case (.left, .castle(side: .bottom)):
                    bottomCoordinates
                default:
                    //No change in doors has happened
                    break
            }
        }
    }
}
