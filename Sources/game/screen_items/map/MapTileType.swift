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
	case ice // TODO: slips and skips to another tile!

	// MARK: Other

	case path
	case building(tile: BuildingTile)
	case player
	case door(tile: DoorTile)

	// MARK: Dont Generate

	case TOBEGENERATED
	case playerStart
	case biomeTOBEGENERATED(type: BiomeType)

	// MARK: Building Stuff

	case station(station: StationTile)
	case startMining
	case chest /* (tile: ChestTile) */
	case bed
	case desk

	// MARK: Crops

	case fence
	case gate
	// TODO: rename crop -> tile
	case crop(crop: CropTile)
	case pot(tile: PotTile)

	// MARK: NPC

	case npc(tile: NPCTile)
	case shopStandingArea(type: ShopStandingAreaType)

	var isBuildable: Bool {
		switch self {
			case .building, .door, .fence, .gate, .chest, .bed, .desk: true
			default: false
		}
	}

	func render() -> String {
		switch self {
			case .plain: " "
			case .water: "W".styled(with: .brightBlue)
			case .path: "P"
			case .tree: (Game.config.useNerdFont ? "󰐅" : "T").styled(with: .green)
			case let .building(tile: buildingTile): "#".styled(with: .dim, styledIf: Game.isBuilding && buildingTile.isPlacedByPlayer)
			case .player: "@".styled(with: [.blue, .bold])
			case .sand: "S".styled(with: .yellow)
			case let .door(doorTile): DoorTile.renderDoor(tile: doorTile)
			case .TOBEGENERATED: "."
			case .playerStart: " "
			case .snow: "S".styled(with: .bold)
			case .snow_tree: (Game.config.useNerdFont ? "󰐅" : "T").styled(with: .bold)
			case .cactus: (Game.config.useNerdFont ? "󰶵" : "C").styled(with: .brightGreen)
			case .ice: "I".styled(with: .brightCyan)
			case .fence: (Game.config.useNerdFont ? "f" : "f").styled(with: .brown)
			case .gate: "g"
			case let .crop(crop: cropTile): CropTile.renderCrop(tile: cropTile)
			case let .pot(tile: potTile): PotTile.renderCropInPot(tile: potTile)
			case let .station(station: station): StationTile.render(tile: station)
			case .startMining: "M"
			case let .npc(tile: tile): NPCTile.renderNPC(tile: tile)
			case .shopStandingArea(type: _): "."
			case .biomeTOBEGENERATED(type: _): "/"
			case .chest /* (tile: _) */: (Game.config.useNerdFont ? "󰜦" : "C").styled(with: .yellow)
			case .bed: Game.config.useNerdFont ? "" : "B"
			case .desk: Game.config.useNerdFont ? "󱈹" : "D"
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
			case let .door(tile): tile.tileType.name
			case .TOBEGENERATED: "TOBEGENERATED"
			case .playerStart: "playerStart"
			case let .station(station: station): station.tileType.name
			case .startMining: "startMining"
			case .fence: "fence"
			case .gate: "gate"
			case let .crop(crop):
				crop.tileType.rawValue
			case let .pot(tile):
				tile.cropTile.tileType.rawValue
			case let .npc(tile):
				tile.tileType.render
			case let .shopStandingArea(type):
				type.rawValue
			case let .biomeTOBEGENERATED(type: biome):
				biome.rawValue
			case .chest: "chest"
			case .bed: "bed"
			case .desk: "desk"
		}
	}

	func specialAction(direction: Direction, player: inout Player, grid: [[MapTile]]) {
		func isWalkable(x: Int, y: Int) -> Bool {
			guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
			return grid[y][x].isWalkable
		}
		switch self {
			case .ice:
				switch direction {
					case .up where isWalkable(x: player.x, y: player.y - 1):
						player.y -= 1
					case .down where isWalkable(x: player.x, y: player.y + 1):
						player.y += 1
					case .left where isWalkable(x: player.x - 1, y: player.y):
						player.x -= 1
					case .right where isWalkable(x: player.x + 1, y: player.y):
						player.x += 1
					default:
						break
				}
			default:
				return
		}
	}
}

enum ShopStandingAreaType: String, Codable {
	case buy, sell, help
}

enum BiomeType: String, Codable {
	case plains, desert, snow, forest
}
