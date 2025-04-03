import Foundation

enum MapTileEvent: TileEvent {
	case openDoor
	case chopTree
	case startMining
	case talkToNPC
	case collectCrop
	case useStation
	case editKingdom
	case editVillage(villageID: UUID)
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
					await tile.npc?.talk()
				} else if case .shopStandingArea = await MapBox.tilePlayerIsOn.type {
					await SVSalesmanNPC.talk()
				} else {
					Logger.warning("No NPC found at this tile")
				}
			case .collectCrop:
				await CollectCropEvent.collectCrop()
			case .useStation:
				await UseStationEvent.useStation()
			case let .editVillage(villageID):
				guard let village = await Game.shared.kingdom.get(villageID: villageID) else { return }
				await Screen.popUp(EditVillagePopUp(village: village)) {
					await MapBox.mapBox()
				}
			case .editKingdom:
				await Screen.popUp(EditKingdomPopUp()) {
					await MapBox.mapBox()
				}
		}
	}
}
