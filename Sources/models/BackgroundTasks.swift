import Foundation

// TODO: run on load
enum BackgroundTasks {
	static func startNPCMovingQueue() {
		Task.detached(priority: .background) {
			guard await !Game.shared.hasStartedNPCQueue else { return }
			await Game.shared.setHasStartedNPCMovingQueue(true)

			Logger.debug("Started NPC task")

			while true {
				let npcPositions = await Game.shared.movingNpcs
				if npcPositions.isEmpty {
					await Game.shared.setHasStartedNPCMovingQueue(false)
					break
				}

				for position in npcPositions {
					if await Game.shared.player.mapType == position.mapType {
						await NPCTile.move(position: position)
					}
				}
				try? await Task.sleep(nanoseconds: 500_000_000) // .5 seconds
			}

			Logger.debug("Ended NPC task")
		}
	}

	static func startCropQueue() {
		// TODO: building maps?
		Task.detached(priority: .background) {
			guard await !Game.shared.hasStartedCropQueue else { return }
			await Game.shared.setHasStartedCropQueue(true)

			Logger.debug("Started crops task")

			while true {
				if await Game.shared.crops.isEmpty {
					await Game.shared.setHasStartedCropQueue(false)
					break
				}
				for position in await Game.shared.crops {
					switch position.mapType {
						case .custom:
							// TODO: custom map crop growing maybe?
							break
						case .farm:
							let tile = await Game.shared.maps.farm[position.y][position.x]
							if case let .pot(tile: pot) = tile.type {
								var newPotTile = PotTile(cropTile: pot.cropTile)
								newPotTile.grow()
								if newPotTile.cropTile.stage == .mature {
									await Game.shared.removeCrop(position)
								}
								let isInsideFarm = await MapBox.mapType == .farm(type: .main)
								let isInsideFarm2 = await MapBox.mapType == .farm(type: .farm_area)
								if isInsideFarm || isInsideFarm2 {
									await MapBox.setMapGridTile(x: position.x, y: position.y, tile: .init(type: .pot(tile: newPotTile), isWalkable: tile.isWalkable, event: tile.event, biome: tile.biome), mapType: position.mapType)
									if newPotTile.cropTile.stage != pot.cropTile.stage {
										await MapBox.buildingMap.updateTile(x: position.x, y: position.y)
									}
								} else {
									await Game.shared.maps.updateMap(mapType: .farm(type: .main), x: position.x, y: position.y, tile: .init(type: .pot(tile: newPotTile), isWalkable: tile.isWalkable, event: tile.event, biome: tile.biome))
								}
							}
						case .mainMap:
							let tile = await MapBox.mainMap.grid[position.y][position.x]
							if case let .crop(crop) = tile.type {
								var newCropTile = CropTile(type: crop.type, growthStage: crop.growthStage)
								newCropTile.grow()
								await MapBox.setMapGridTile(x: position.x, y: position.y, tile: .init(type: .crop(crop: newCropTile), isWalkable: tile.isWalkable, event: tile.event, biome: tile.biome), mapType: position.mapType)
							} else if case let .pot(tile: pot) = tile.type {
								var newPotTile = PotTile(cropTile: pot.cropTile)
								newPotTile.grow()
								await MapBox.setMapGridTile(x: position.x, y: position.y, tile: .init(type: .pot(tile: newPotTile), isWalkable: tile.isWalkable, event: tile.event, biome: tile.biome), mapType: position.mapType)
							}
						default: break
					}
				}
				try? await Task.sleep(for: .seconds(1))
			}
			Logger.debug("Ended crops task")
		}
	}
}
