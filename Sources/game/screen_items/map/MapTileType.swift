enum MapTileType: TileType {
	// MARK: Plains Biome

	case plain
	case water
	case tree

	// MARK: Desert Biome

	case sand
	case cactus

	// MARK: Snow Biome

	case snow
	case snow_tree
	case ice

	// MARK: Other Biome

	case stone
	case lava
	case mud

	// MARK: Other

	case path // TODO: Make buildable
	case player

	// MARK: Buildable

	case building(tile: BuildingTile)
	case door(tile: DoorTile)
	case chest /* (tile: ChestTile) */
	case bed(tile: BedTile)
	case desk(tile: DeskTile)
	case fence(tile: FenceTile)
	case gate(tile: GateTile)

	// MARK: Dont Generate

	case TOBEGENERATED
	case playerStart
	case biomeTOBEGENERATED(type: BiomeType)

	// MARK: Building Stuff

	case station(station: StationTile)
	case startMining

	// MARK: Crops

	// TODO: rename crop -> tile
	case crop(crop: CropTile)
	case pot(tile: PotTile)

	// MARK: NPC

	case npc(tile: NPCTile)
	case shopStandingArea(type: ShopStandingAreaType)

	var isBuildable: Bool {
		switch self {
			case .building, .door, .fence, .gate, .chest, .bed, .desk, .path: true
			default: false
		}
	}

	var isPlainLike: Bool {
		switch self {
			case .plain, .snow, .sand, .path, .water, .ice: true
			default: false
		}
	}

	func render() async -> String {
		let tile = await MapBox.tilePlayerIsOn
		switch self {
			case .plain: return " "
			case .water:
				if await Game.shared.config.useHighlightsForPlainLikeTiles {
					return " ".styled(with: [.brightBlue, .inverted])
				} else {
					return "W".styled(with: .brightBlue)
				}
			case .path: return "P"
			case .tree: return await (Game.shared.config.useNerdFont ? "󰐅" : "T").styled(with: .green)
			// case let .building(tile: buildingTile): return await "█".styled(with: .dim, styledIf: Game.shared.isBuilding && buildingTile.isPlacedByPlayer)
			case let .building(tile: buildingTile): return await Game.shared.config.icons.buildingIcon.styled(with: .dim, styledIf: Game.shared.isBuilding && buildingTile.isPlacedByPlayer)
			case .player:
				let use = await Game.shared.config.useHighlightsForPlainLikeTiles
				return await Game.shared.config.icons.characterIcon.styled(with: [.blue, .bold])
					.styled(with: .highlightYellow, styledIf: tile.type == .sand && use)
					.styled(with: .highlightBrightWhite, styledIf: tile.type == .snow && use)
					.styled(with: .highlightBrightCyan, styledIf: tile.type == .ice && use)
					.styled(with: .highlightBrown, styledIf: tile.type == .mud && use)
					.styled(with: [.highlightBrightBlue], styledIf: tile.type == .water && use)
			case .sand:
				if await Game.shared.config.useHighlightsForPlainLikeTiles {
					return " ".styled(with: [.yellow, .inverted])
				} else {
					return "S".styled(with: .yellow)
				}
			case let .door(doorTile): return await DoorTile.renderDoor(tile: doorTile)
			case .TOBEGENERATED: return "."
			case .playerStart: return " "
			case .snow:
				if await Game.shared.config.useHighlightsForPlainLikeTiles {
					return " ".styled(with: [.brightWhite, .inverted])
				} else {
					return "S".styled(with: .bold)
				}
			case .snow_tree: return await (Game.shared.config.useNerdFont ? "󰐅" : "T").styled(with: .brightWhite)
			case .cactus:
				let use = await Game.shared.config.useHighlightsForPlainLikeTiles
				return await (Game.shared.config.useNerdFont ? "󰶵" : "C").styled(with: .brightGreen).styled(with: .highlightYellow, styledIf: use)
			case .ice:
				if await Game.shared.config.useHighlightsForPlainLikeTiles {
					return " ".styled(with: [.brightCyan, .inverted])
				} else {
					return "I".styled(with: .brightCyan)
				}
			case .fence: return await (Game.shared.config.useNerdFont ? "f" : "f").styled(with: .brown)
			case .gate: return "g"
			case let .crop(crop: cropTile): return await CropTile.renderCrop(tile: cropTile)
			case let .pot(tile: potTile): return await PotTile.renderCropInPot(tile: potTile)
			case let .station(station: station): return StationTile.render(tile: station)
			case .startMining: return "M"
			case let .npc(tile: tile): return await NPCTile.renderNPC(tile: tile)
			case .shopStandingArea(type: _): return "."
			case .biomeTOBEGENERATED(type: _): return "/"
			case .chest /* (tile: _) */: return await (Game.shared.config.useNerdFont ? "󰜦" : "C").styled(with: .yellow)
			case .bed: return await Game.shared.config.useNerdFont ? "" : "B"
			case .desk: return await Game.shared.config.useNerdFont ? "󱈹" : "D"
			case .stone:
				if await Game.shared.config.useHighlightsForPlainLikeTiles {
					return " ".styled(with: .highlightBrightBlack)
				} else {
					return "S".styled(with: .dim)
				}
			case .lava:
				if await Game.shared.config.useHighlightsForPlainLikeTiles {
					return " ".styled(with: [.red, .inverted])
				} else {
					return "L".styled(with: .red)
				}
			case .mud:
				if await Game.shared.config.useHighlightsForPlainLikeTiles {
					return " ".styled(with: [.brown, .inverted])
				} else {
					return "M".styled(with: .brown)
				}
		}
	}

	var name: String {
		switch self {
			case .plain: "plain"
			case .water: "water"
			case .tree: "tree"
			case .sand: "sand"
			case .cactus: "cactus"
			case .snow: "snow"
			case .snow_tree: "snow_tree"
			case .ice: "ice"
			case .path: "path"
			case .building: "building"
			case .player: "player"
			case let .door(tile): tile.type.name
			case .TOBEGENERATED: "TOBEGENERATED"
			case .playerStart: "playerStart"
			case let .station(station: station): station.type.name
			case .startMining: "startMining"
			case .fence: "fence"
			case .gate: "gate"
			case let .crop(crop):
				crop.type.rawValue
			case let .pot(tile):
				tile.cropTile.type.rawValue
			case let .npc(tile):
				tile.npc.job?.render ?? "None"
			case let .shopStandingArea(type):
				type.rawValue
			case let .biomeTOBEGENERATED(type: biome):
				biome.rawValue
			case .chest: "chest"
			case .bed: "bed"
			case .desk: "desk"
			case .stone: "stone"
			case .lava: "lava"
			case .mud: "mud"
		}
	}

	func specialAction(direction: PlayerDirection, grid: [[MapTile]]) async {
		let player = await Game.shared.player.position
		func isWalkable(x: Int, y: Int) -> Bool {
			guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
			if case .building = grid[y][x].type {
				return false
			}
			return grid[y][x].isWalkable
		}
		switch self {
			case .ice:
				switch direction {
					case .up where isWalkable(x: player.x, y: player.y - 1):
						await Game.shared.player.setPlayerPosition(addY: -1)
					case .down where isWalkable(x: player.x, y: player.y + 1):
						await Game.shared.player.setPlayerPosition(addY: 1)
					case .left where isWalkable(x: player.x - 1, y: player.y):
						await Game.shared.player.setPlayerPosition(addX: -1)
					case .right where isWalkable(x: player.x + 1, y: player.y):
						await Game.shared.player.setPlayerPosition(addX: 1)
					default:
						break
				}
			default:
				return
		}
	}
}

enum ShopStandingAreaType: String, Hashable, Codable {
	case buy, sell, help
}

enum BiomeType: String, Hashable, Codable {
	case plains, desert, snow, forest, volcano, tundra, ocean, coast, swamp, mountain
}
