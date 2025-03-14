import Foundation

struct NPCTile: Codable, Hashable, Equatable {
	let id: UUID
	let type: NPCTileType
	var npc: NPC
	private(set) var positionToWalkTo: TilePosition?

	init(id: UUID = UUID(), type: NPCTileType, positionToWalkTo: TilePosition? = nil, tilePosition: NPCPosition?) {
		self.id = id
		self.type = type
		self.positionToWalkTo = positionToWalkTo
		if let tilePosition {
			Task {
				await Game.shared.addNPC(tilePosition)
			}
		}
		self.npc = .init(isStartingVillageNPC: false, tileID: id)
	}

	mutating func removePostion() {
		positionToWalkTo = nil
	}

	static func renderNPC(tile: NPCTile) async -> String {
		if await !tile.type.hasTalkedToBefore {
			return "!".styled(with: [.bold, .red])
		}
		switch tile.type {
			default:
				// TODO: Not sure if this will stay
				if tile.positionToWalkTo != nil {
					return await (Game.shared.config.useNerdFont ? "" : "N").styled(with: .bold)
				} else {
					return await (Game.shared.config.useNerdFont ? "󰙍" : "N").styled(with: .bold)
				}
		}
	}

	var queueName: String {
		"\(type.queueName).\(id)"
	}

	func talk() async {
		switch type {
			case .blacksmith:
				await BlacksmithNPC.talk()
			case .blacksmith_helper:
				await BlacksmithHelperNPC.talk()
			case .miner:
				await MinerNPC.talk()
			case .mine_helper:
				await MineHelperNPC.talk()
			case .carpenter:
				await CarpenterNPC.talk()
			case .carpenter_helper:
				await CarpenterHelperNPC.talk()
			case .king:
				await KingNPC.talk()
			case .salesman:
				await SalesmanNPC.talk()
			case .builder:
				await BuilderNPC.talk()
			case .builder_helper:
				await BuilderHelperNPC.talk()
			case .hunter:
				await HunterNPC.talk()
			case .inventor:
				break
			case .stable_master:
				break
			case .farmer:
				await FarmerNPC.talk()
			case .doctor:
				break
			case .chef:
				break
			case .potter:
				await PotterNPC.talk()
			case .farmer_helper:
				await FarmerHelperNPC.talk()
			case .citizen:
				// await CitizenNPC.talk()
				break
		}
	}

	static func move(position: NPCPosition) async {
		let npcTile = await MapBox.mapType.map.grid[position.y][position.x] as! MapTile

		if case let .npc(npc) = npcTile.type, let positionToWalkTo = npc.positionToWalkTo {
			if positionToWalkTo == .init(x: position.x, y: position.y, mapType: position.mapType) {
				await Game.shared.removeNPC(position)
				var npcNew = npc
				npcNew.removePostion()
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
							type: .npc(tile: npc),
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
		try container.encode(type, forKey: .tileType)
		try container.encodeIfPresent(positionToWalkTo, forKey: .positionToWalkTo)
		try container.encode(npc, forKey: .npc)
	}

	enum CodingKeys: CodingKey {
		case id
		case tileType
		case canWalk
		case positionToWalkTo
		case npc
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.type = try container.decode(NPCTileType.self, forKey: .tileType)
		self.positionToWalkTo = try container.decodeIfPresent(TilePosition.self, forKey: .positionToWalkTo)
		self.npc = try container.decode(NPC.self, forKey: .npc)
	}
}
