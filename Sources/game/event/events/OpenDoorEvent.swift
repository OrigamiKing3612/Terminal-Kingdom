enum OpenDoorEvent {
	static func openDoor(doorTile: DoorTile) async {
		if await await MapBox.mapType != .mainMap, await await MapBox.mapType != .mining {
			await leaveBuildingMap()
		} else {
			switch doorTile.type {
				case .castle: await CastleDoorEvent.open(tile: doorTile)
				case .blacksmith: await BlacksmithDoorEvent.open(tile: doorTile)
				case .mine: await MineDoorEvent.open(tile: doorTile)
				case .shop: await ShopDoorEvent.open(tile: doorTile)
				case .builder: await BuilderDoorEvent.open(tile: doorTile)
				case .hunting_area: await HuntingAreaDoorEvent.open(tile: doorTile)
				case .inventor: await InventorDoorEvent.open(tile: doorTile)
				case .house: await HouseDoorEvent.open(tile: doorTile)
				case .stable: await StableDoorEvent.open(tile: doorTile)
				case .farm: await FarmDoorEvent.open(tile: doorTile)
				case .hospital: await HospitalDoorEvent.open(tile: doorTile)
				case .carpenter: await CarpenterDoorEvent.open(tile: doorTile)
				case .restaurant: await RestaurantDoorEvent.open(tile: doorTile)
				case .potter: await PotterAreaDoorEvent.open(tile: doorTile)
				case let .custom(mapID: mapID, doorType: doorType): await CustomDoorEvent.open(tile: doorTile, mapID: mapID, doorType: doorType)
			}
		}
	}

	private static func leaveBuildingMap() async {
		let currentTile = await await MapBox.tilePlayerIsOn

		switch await await MapBox.mapType {
			case let .farm(type: farmType):
				if case let .door(playerDoorTile) = currentTile.type {
					// enter, out
					switch (farmType, playerDoorTile.type) {
						case (.main, .farm(type: .farm_area)):
							await MapBox.setMainMapPlayerPosition(DoorTileTypes.farm(type: .main).coordinatesForStartingVillageBuildings)
						case (.farm_area, .farm(type: .main)):
							await MapBox.setMainMapPlayerPosition(DoorTileTypes.farm(type: .farm_area).coordinatesForStartingVillageBuildings)
						default:
							// No change in doors has happened
							break
					}
				}
			case let .castle(side: castleSide):
				await exitCastle(castleSide: castleSide, currentTile: currentTile)
			case let .hospital(side: hospitalSide):
				if case let .door(playerDoorTile) = currentTile.type {
					// enter, out
					switch (hospitalSide, playerDoorTile.type) {
						case (.top, .hospital(side: .bottom)):
							await MapBox.setMainMapPlayerPosition(DoorTileTypes.hospital(side: .bottom).coordinatesForStartingVillageBuildings)
						case (.bottom, .hospital(side: .top)):
							await MapBox.setMainMapPlayerPosition(DoorTileTypes.hospital(side: .top).coordinatesForStartingVillageBuildings)
						default:
							// No change in doors has happened
							break
					}
				}
			default:
				break
		}

		// Return to the main map
		await MapBox.setMapType(.mainMap)
	}

	private static func exitCastle(castleSide: CastleSide, currentTile: MapTile) async {
		var topCoordinates: Void {
			get async {
				await MapBox.setMainMapPlayerPosition(DoorTileTypes.castle(side: .top).coordinatesForStartingVillageBuildings)
			}
		}
		var rightCoordinates: Void {
			get async {
				await MapBox.setMainMapPlayerPosition(DoorTileTypes.castle(side: .right).coordinatesForStartingVillageBuildings)
			}
		}
		var bottomCoordinates: Void {
			get async {
				await MapBox.setMainMapPlayerPosition(DoorTileTypes.castle(side: .bottom).coordinatesForStartingVillageBuildings)
			}
		}
		var leftCoordinates: Void {
			get async {
				await MapBox.setMainMapPlayerPosition(DoorTileTypes.castle(side: .left).coordinatesForStartingVillageBuildings)
			}
		}
		if case let .door(playerDoorTile) = currentTile.type {
			// enter, out
			switch (castleSide, playerDoorTile.type) {
				case (.top, .castle(side: .right)):
					await rightCoordinates
				case (.top, .castle(side: .bottom)):
					await bottomCoordinates
				case (.top, .castle(side: .left)):
					await leftCoordinates
				case (.right, .castle(side: .top)):
					await topCoordinates
				case (.right, .castle(side: .bottom)):
					await bottomCoordinates
				case (.right, .castle(side: .left)):
					await leftCoordinates
				case (.bottom, .castle(side: .top)):
					await topCoordinates
				case (.bottom, .castle(side: .right)):
					await rightCoordinates
				case (.bottom, .castle(side: .left)):
					await leftCoordinates
				case (.left, .castle(side: .top)):
					await topCoordinates
				case (.left, .castle(side: .right)):
					await rightCoordinates
				case (.left, .castle(side: .bottom)):
					await bottomCoordinates
				default:
					// No change in doors has happened
					break
			}
		}
	}
}
