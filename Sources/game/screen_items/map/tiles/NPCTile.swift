import Foundation

struct NPCTile: Codable, Hashable, Equatable {
	let id: UUID
	var npc: NPC

	init(id: UUID = UUID(), tilePosition: NPCPosition?) {
		self.id = id
		if let tilePosition {
			Task {
				await Game.shared.addNPC(tilePosition)
			}
		}
		self.npc = .init(tileID: id, isStartingVillageNPC: false)
	}

	static func renderNPC(tile: NPCTile) async -> String {
		if !tile.npc.hasTalkedToBefore {
			return "!".styled(with: [.bold, .red])
		}
		switch tile.npc.job {
			default:
				// TODO: Not sure if this will stay
				if tile.npc.positionToWalkTo != nil {
					return await (Game.shared.config.useNerdFont ? "" : "N").styled(with: .bold)
				} else {
					return await (Game.shared.config.useNerdFont ? "󰙍" : "N").styled(with: .bold)
				}
		}
	}

	static func move(position: NPCPosition) async {
		let npcTile = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile

		if case let .npc(tile) = npcTile.type, let positionToWalkTo = tile.npc.positionToWalkTo {
			if positionToWalkTo == .init(x: position.x, y: position.y, mapType: position.mapType) {
				await Game.shared.removeNPC(position)
				var npcNew = tile
				npcNew.npc.removePostion()
				await MapBox.updateTile(newTile: MapTile(
					type: .npc(tile: npcNew),
					isWalkable: npcTile.isWalkable,
					event: npcTile.event,
					biome: npcTile.biome
				), thisOnlyWorksOnMainMap: true, x: position.x, y: position.y)
				return
			}
			let newNpcPosition = await NPCMoving.move(
				target: positionToWalkTo,
				current: .init(x: position.x, y: position.y, mapType: position.mapType)
			)

			let currentTile = await MapBox.mapType.map.grid[newNpcPosition.y][newNpcPosition.x] as! MapTile

			let newPosition = NPCPosition(
				x: newNpcPosition.x,
				y: newNpcPosition.y,
				mapType: position.mapType,
				oldTile: currentTile
			)

			await withTaskGroup(of: Void.self) { group in
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
		try container.encode(npc, forKey: .npc)
	}

	enum CodingKeys: CodingKey {
		case id
		case npc
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.npc = try container.decode(NPC.self, forKey: .npc)
	}
}
