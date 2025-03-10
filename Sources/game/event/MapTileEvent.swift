enum MapTileEvent: TileEvent {
	case openDoor
	case chopTree
	case startMining
	case talkToNPC
	case collectCrop
	case useStation
	//    case collectItem(item: String)
	//    case combat(enemy: String)

	static func trigger(event: MapTileEvent) async {
		switch event {
			case .openDoor:
				if case let .door(tile: doorTile) = await MapBox.tilePlayerIsOn.type {
					await OpenDoorEvent.openDoor(doorTile: doorTile)
				}
			case .chopTree:
				if await Game.shared.player.hasAxe() {
					await ChopTreeEvent.chopTree()
				} else {
					await MessageBox.message("Ouch!", speaker: .game)
				}
			case .startMining:
				if await Game.shared.player.hasPickaxe() {
					await StartMiningEvent.startMining()
				} else {
					await MessageBox.message("You need a pickaxe to start mining", speaker: .miner)
				}
			case .talkToNPC:
				if case let .npc(tile: tile) = await MapBox.tilePlayerIsOn.type {
					await tile.talk()
				} else if case .shopStandingArea = await MapBox.tilePlayerIsOn.type {
					await SalesmanNPC.talk()
				}
			case .collectCrop:
				await CollectCropEvent.collectCrop()
			case .useStation:
				await UseStationEvent.useStation()
		}
	}

	var name: String {
		get async {
			switch self {
				case .openDoor:
					if case let .door(tile: doorTile) = await MapBox.tilePlayerIsOn.type {
						"openDoor(\(doorTile.type.name))"
					} else {
						"openDoor on non door"
					}
				case .chopTree:
					"chopTree"
				case .startMining:
					"startMining"
				case .talkToNPC:
					if case let .npc(tile: tile) = await MapBox.tilePlayerIsOn.type {
						"talkToNPC(\(tile.type.render))"
					} else {
						"talkToNPC on non npc"
					}
				case .collectCrop:
					"collectCrop"
				case .useStation:
					if case let .station(station: station) = await MapBox.tilePlayerIsOn.type {
						"useStation(\(station.type.render))"
					} else {
						"useStation on non station"
					}
			}
		}
	}
}
