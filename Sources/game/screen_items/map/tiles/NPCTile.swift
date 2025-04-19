import Foundation

struct NPCTile: Codable, Hashable, Equatable {
	static let startingVillageID = UUID()
	let id: UUID
	let npcID: UUID
	var npc: NPC? {
		get async {
			let npc = await Game.shared.npcs[npcID]
			assert(npc != nil, "NPC not found for NPCTile with ID: \(id) and npcID: \(npcID)")
			return npc
		}
	}

	private init(id: UUID = UUID(), npcID: UUID) {
		self.id = id
		self.npcID = npcID
	}

	init(id: UUID = UUID(), npc: NPC) {
		self.id = id
		self.npcID = npc.id
		Task {
			await Game.shared.npcs.add(npc: npc)
		}
	}

	static func renderNPC(tile: NPCTile) async -> String {
		guard let npc = await tile.npc else { return "?" }
		if !npc.hasTalkedToBefore {
			if let job = npc.job, !job.isNotLead {
				return "!".styled(with: [.bold, .red])
			}
		}
		switch npc.job {
			default:
				if npc.positionToWalkTo != nil {
					return await (Game.shared.config.useNerdFont ? "" : "N").styled(with: .bold)
				} else {
					let nerdFontSymbol = npc.gender == .male ? "󰙍" : "󰙉"
					return await (Game.shared.config.useNerdFont ? nerdFontSymbol : "N").styled(with: .bold)
				}
		}
	}

	static func move(position: NPCMovingPosition) async {
		// Logger.debug("\(#function) \(#file):\(#line): Moving NPC from \(position.x), \(position.y)")
		let npcTile = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile

		if case let .npc(tile: tile) = npcTile.type, let npc = await tile.npc, let positionToWalkTo = npc.positionToWalkTo {
			// Reached the destination
			if positionToWalkTo == .init(x: position.x, y: position.y, mapType: position.mapType) {
				await Game.shared.removeNPC(position)
				if case let .door(doorTile) = position.oldTile.type {
					if case let .custom(mapID, _) = doorTile.type {
						// TODO: fix this when multidoors in custom maps
						guard let mapID else { return }
						guard let grid = await Game.shared.maps.customMaps[mapID]?.grid else { return }

						for (yIndex, y) in grid.enumerated() {
							if let xIndex = y.firstIndex(where: { if case .door = $0.type { true } else { false }}) {
								// Restore the door tile
								await MapBox.updateTile(newTile: MapTile(
									type: .door(tile: doorTile),
									isWalkable: npcTile.isWalkable,
									event: npcTile.event,
									biome: npcTile.biome
								), x: position.x, y: position.y)
								var doorPosition: DoorPosition = .bottom
								if yIndex == 0 {
									doorPosition = .top
								} else if yIndex == grid.count - 1 {
									doorPosition = .bottom
								} else if xIndex == 0 {
									doorPosition = .left
								} else if xIndex == grid[yIndex].count - 1 {
									doorPosition = .right
								}
								let npcX: Int
								let npcY: Int
								switch doorPosition {
									case .left:
										npcX = xIndex + 1
										npcY = yIndex + 1
									case .right:
										npcX = xIndex - 1
										npcY = yIndex - 1
									case .top:
										npcX = xIndex - 1
										npcY = yIndex + 1
									case .bottom:
										npcX = xIndex + 1
										npcY = yIndex - 1
								}

								var newGrid = grid
								await Game.shared.npcs.removeNPCPosition(npcID: tile.npcID)
								newGrid[npcY][npcX] = MapTile(
									type: .npc(tile: .init(id: tile.id, npcID: tile.npcID)),
									isWalkable: npcTile.isWalkable,
									event: npcTile.event,
									biome: npcTile.biome
								)
								await Game.shared.maps.updateCustomMap(id: mapID, with: newGrid)
								break
							}
						}

					} else {}
					// put npcID in the custom map
					return
				} else {
					await Game.shared.npcs.removeNPCPosition(npcID: tile.npcID)
					await MapBox.updateTile(newTile: MapTile(
						type: .npc(tile: .init(id: tile.id, npcID: tile.npcID)),
						isWalkable: npcTile.isWalkable,
						event: npcTile.event,
						biome: npcTile.biome
					), x: position.x, y: position.y)
					return
				}
			}
			let newNpcPosition = await NPCMoving.move(
				target: positionToWalkTo,
				current: .init(x: position.x, y: position.y, mapType: position.mapType)
			)
			guard await MapBox.mapType == position.mapType else { return }
			let currentTile = await MapBox.mapType.map.grid[newNpcPosition.y][newNpcPosition.x] as! MapTile

			let newPosition = NPCMovingPosition(
				x: newNpcPosition.x,
				y: newNpcPosition.y,
				mapType: position.mapType,
				oldTile: currentTile
			)

			await withTaskGroup { group in
				group.addTask {
					// Restore old tile
					await MapBox.setMapGridTile(
						x: position.x,
						y: position.y,
						tile: position.oldTile,
						mapType: position.mapType
					)
				}

				group.addTask {
					// Update new tile to NPC
					await MapBox.setMapGridTile(
						x: newNpcPosition.x,
						y: newNpcPosition.y,
						tile: MapTile(
							type: .npc(tile: tile),
							isWalkable: npcTile.isWalkable,
							event: npcTile.event,
							biome: npcTile.biome
						),
						mapType: position.mapType
					)
				}

				group.addTask {
					await Game.shared.updateNPC(oldPosition: position, newPosition: newPosition)
				}

				group.addTask {
					await MapBox.updateTwoTiles(x1: newNpcPosition.x, y1: newNpcPosition.y, x2: position.x, y2: position.y)
				}
			}
		}
	}
}

extension NPCTile {
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(npcID, forKey: .npcID)
	}

	enum CodingKeys: CodingKey {
		case id
		case npcID
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.npcID = try container.decode(UUID.self, forKey: .npcID)
	}
}
