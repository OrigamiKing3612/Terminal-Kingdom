enum MapTileEvent: TileEvent {
	case openDoor
	case chopTree
	case startMining
	case talkToNPC
	case collectCrop
	case useStation
	//    case collectItem(item: String)
	//    case combat(enemy: String)

	static func trigger(event: MapTileEvent) {
		switch event {
			case .openDoor:
				if case let .door(tile: doorTile) = MapBox.tilePlayerIsOn.type {
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
			case .talkToNPC:
				if case let .npc(tile: tile) = MapBox.tilePlayerIsOn.type {
					tile.talk()
				} else if case .shopStandingArea = MapBox.tilePlayerIsOn.type {
					SalesmanNPC.talk()
				}
			case .collectCrop:
				let tile = MapBox.tilePlayerIsOn
				if case let .crop(crop: crop) = tile.type {
					CollectCropEvent.collectCrop(cropTile: crop, isInPot: false)
				} else if case let .pot(tile: tile) = tile.type {
					if tile.cropTile.type != .none {
						CollectCropEvent.collectCrop(cropTile: tile.cropTile, isInPot: true)
					} else {
						if !Game.player.has(item: .tree_seed) {
							MessageBox.message("There is no crop here", speaker: .game)
							return
						}
						let options: [MessageOption] = [.init(label: "Quit", action: {}), .init(label: "Plant Seed", action: {
							MapBox.updateTile(newTile: .init(type: .pot(tile: .init(cropTile: .init(type: .tree_seed)))))
						})]
						let selectedOption = MessageBox.messageWithOptions("Plant Seed", speaker: .game, options: options)
						selectedOption.action()
					}
				}
			case .useStation:
				UseStationEvent.useStation()
		}
	}

	var name: String {
		switch self {
			case .openDoor:
				if case let .door(tile: doorTile) = MapBox.tilePlayerIsOn.type {
					"openDoor(\(doorTile.type.name))"
				} else {
					"openDoor on non door"
				}
			case .chopTree:
				"chopTree"
			case .startMining:
				"startMining"
			case .talkToNPC:
				if case let .npc(tile: tile) = MapBox.tilePlayerIsOn.type {
					"talkToNPC(\(tile.type.render))"
				} else {
					"talkToNPC on non npc"
				}
			case .collectCrop:
				"collectCrop"
			case .useStation:
				if case let .station(station: station) = MapBox.tilePlayerIsOn.type {
					"useStation(\(station.type.render))"
				} else {
					"useStation on non station"
				}
		}
	}
}
