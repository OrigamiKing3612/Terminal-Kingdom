import Foundation

enum CustomDoorEvent {
	static func open(tile: DoorTile, mapID: UUID?, doorType _: DoorTileTypes) async {
		guard let mapID else {
			await MessageBox.message("This building doesn't have an inside. Try breaking and replacing the door.", speaker: .game)
			return
		}
		var options: [MessageOption] = [
			.init(label: "Go Inside", action: { await goInside(tile: tile, mapID: mapID) }),
		]

		let x = await Game.shared.player.position.x
		let y = await Game.shared.player.position.y
		if let building = await Game.shared.kingdom.hasVillageBuilding(x: x, y: y) {
			if await building.canBeUpgraded() {
				options.append(.init(label: "Upgrade", action: { await upgrade(building: building) }))
			}
			if let house = building as? HouseBuilding {
				let villageID = await Game.shared.kingdom.getVillage(x: x, y: y)!.id
				options.append(.init(label: "Manage Residents", action: { await Screen.popUp(ManageResidentsPopUp(house: house, villageID: villageID)) { await MapBox.mapBox() } }))
			}
		}
		options.append(.init(label: "Quit", action: {}))
		await MessageBox.messageWithOptions("What would you like to do?", options: options)
	}

	static func goInside(tile _: DoorTile, mapID: UUID) async {
		await MapBox.setMapType(.custom(mapID: mapID))
	}

	static func upgrade(building: any BuildingProtocol) async {
		let newBuilding = building
		await newBuilding.upgrade()
		guard let kingdom = await Game.shared.kingdom.getVillage(buildingID: building.id) else { return }
		await Game.shared.kingdom.updateVillageBuilding(villageID: kingdom.id, buildingID: building.id, newBuilding: newBuilding)
	}
}
