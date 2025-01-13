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
			case let .openDoor(tile: doorTile):
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
			case let .talkToNPC(tile: tile):
				tile.talk()
			case .collectCrop:
				let tile = MapBox.tilePlayerIsOn
				if case let .crop(crop: crop) = tile.type {
					CollectCropEvent.collectCrop(cropTile: crop, isInPot: false)
				} else if case let .pot(tile: tile) = tile.type {
					if tile.cropTile.type != .none {
						CollectCropEvent.collectCrop(cropTile: tile.cropTile, isInPot: true)
					} else {
						MessageBox.message("There is no crop here", speaker: .game)
					}
				}
			case let .useStation(station: station):
				UseStationEvent.useStation(tile: station)
		}
	}

	var name: String {
		switch self {
			case let .openDoor(tile):
				"openDoor(\(tile.type.name))"
			case .chopTree:
				"chopTree"
			case .startMining:
				"startMining"
			case let .talkToNPC(tile):
				"talkToNPC(\(tile.type.render))"
			case .collectCrop:
				"collectCrop"
			case let .useStation(station: station):
				"useStation(\(station.type.render))"
		}
	}
}
