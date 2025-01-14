struct MainMap: MapBoxMap {
	var grid: [[MapTile]]

	var player: Player {
		get { Game.player.position }
		set { Game.player.updatePlayerPositionToSave(x: newValue.x, y: newValue.y) }
	}

	private var hasFoundPlayerStart = false

	init() {
		grid = Game.map
	}

	var tilePlayerIsOn: MapTile {
		grid[player.y][player.x]
	}

	func isWalkable(x: Int, y: Int) -> Bool {
		guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
		if grid[y][x].type == .building(tile: .init(isPlacedByPlayer: true)) {
			return Game.isBuilding
		}
		return grid[y][x].isWalkable
	}

	func render(playerX: Int, playerY: Int, viewportWidth: Int, viewportHeight: Int) {
		let halfViewportWidth = viewportWidth / 2
		let halfViewportHeight = viewportHeight / 2

		let startX = max(0, playerX - halfViewportWidth)
		let startY = max(0, playerY - halfViewportHeight)

		let endX = min(grid[0].count, startX + viewportWidth)
		let endY = min(grid.count, startY + viewportHeight)

		for (screenY, mapY) in (startY ..< endY).enumerated() {
			var rowString = ""
			for mapX in startX ..< endX {
				if mapX == playerX, mapY == playerY {
					rowString += MapTileType.player.render()
				} else {
					rowString += grid[mapY][mapX].type.render()
				}
			}
			Screen.print(x: MapBox.startX, y: MapBox.startY + screenY, rowString)
		}
	}

	mutating func movePlayer(_ direction: Direction) {
		let oldX = player.x
		let oldY = player.y

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

		tilePlayerIsOn.type.specialAction(direction: direction, player: &player, grid: grid)

		if oldX != player.x || oldY != player.y {
			map()
			StatusBox.position()
		}
	}

	mutating func map() {
		// TODO: could fix #2
		if !hasFoundPlayerStart {
			if let (startX, startY) = MapTile.findTilePosition(of: .playerStart, in: grid) {
				player.x = startX
				player.y = startY
			} else {
				print("Error: Could not find playerStart tile in the grid.")
			}
			hasFoundPlayerStart = true
		}

		let viewportWidth = MapBox.width
		let viewportHeight = MapBox.height
		render(playerX: player.x, playerY: player.y, viewportWidth: viewportWidth, viewportHeight: viewportHeight)
	}

	mutating func setPlayerPosition(_ position: (x: Int, y: Int)) {
		player.x = position.x
		player.y = position.y
	}

	func interactWithTile() {
		let tile = grid[player.y][player.x]
		if tile.isInteractable {
			if let event = tile.event {
				MapTileEvent.trigger(event: event)
			}
		} else {
			MessageBox.message("There is nothing to do here.", speaker: .game)
		}
	}

	mutating func build() {
		if grid[player.y][player.x].type != .plain {
			MessageBox.message("You can't build here.", speaker: .game)
			return
		}
		if Game.player.has(item: .lumber, count: 5) {
			if Game.stages.builder.stage5Stages == .notStarted {
				buildForBuilderStage5()
			} else {
				buildNormally()
			}
		} else {
			MessageBox.message("You need 5 lumber to build a building.", speaker: .game)
		}
	}

	mutating func destory() {
		if grid[player.y][player.x].type.isBuildable {
			removeNormally()
		} else {
			MessageBox.message("You can't remove this tile.", speaker: .game)
		}
	}

	private mutating func removeNormally() {
		let tile = grid[player.y][player.x]
		let x = player.x
		let y = player.y
		if case let .building(tile: buildingTile) = tile.type {
			if buildingTile.isPlacedByPlayer {
				grid[y][x] = MapTile(type: .plain)
				_ = Game.player.collect(item: .init(type: .lumber), count: 4)
			} else {
				MessageBox.message("You can't remove this building.", speaker: .game)
			}
		} else if case let .door(tile: doorTile) = tile.type {
			if doorTile.isPlacedByPlayer {
				grid[y][x] = MapTile(type: .plain)
				_ = Game.player.collect(item: .init(type: .door(tile: doorTile)), count: 1)
			} else {
				MessageBox.message("You can't remove this door.", speaker: .game)
			}
		} else {
			// if doorTile.isPlacedByPlayer {
			// 	grid[player.y][player.x] = MapTile(type: .plain)
			// 	_ = Game.player.collect(item: .init(type: .door(tile: doorTile)), count: 1)
			// } else {
			// 	MessageBox.message("You can't remove this door.", speaker: .game)
			// }
			MessageBox.message("You can't remove this tile.", speaker: .game)
		}
	}

	private mutating func buildNormally() {
		let selectedItem = InventoryBox.buildableItems[InventoryBox.selectedBuildItemIndex]
		if selectedItem.type == .lumber {
			if Game.player.has(item: .lumber, count: 5) {
				grid[player.y][player.x] = MapTile(type: .building(tile: .init(isPlacedByPlayer: true)))
				Game.player.removeItem(item: .lumber, count: 5)
			}
		} else {
			if Game.player.has(item: selectedItem.type, count: 1) {
				if case let .door(tile: tile) = selectedItem.type {
					do {
						try checkDoor(tile: tile)
						grid[player.y][player.x] = MapTile(type: .door(tile: .init(tileType: tile.tileType, isPlacedByPlayer: true)), isWalkable: true, event: .openDoor(tile: .init(tileType: tile.tileType)))
						Game.player.removeItem(item: .door(tile: tile), count: 1)
						if Game.stages.builder.stage5Stages == .buildHouse {
							Game.stages.builder.stage5HasBuiltHouse = true
						}
					} catch {
						MessageBox.message(error.localizedDescription, speaker: .game)
					}
				} else {
					grid[player.y][player.x] = MapTile(type: itemTypeToMapTileType(selectedItem.type)!)
					Game.player.removeItem(item: selectedItem.type, count: 1)
				}
			}
		}
	}

	mutating func updateTile(newTile: MapTile) {
		grid[player.y][player.x] = newTile
	}
}

extension MainMap {
	private mutating func buildForBuilderStage5() {
		var buildingsPlaced: Int { Game.stages.builder.stage5BuildingsPlaced }
		if buildingsPlaced == 0 {
			buildNormally()
			Game.stages.builder.stage5LastBuildingPlaced = .init(x: player.x, y: player.y)
		} else {
			let lastBuildingPlaced = Game.stages.builder.stage5LastBuildingPlaced
			if let lastBuildingPlaced {
				if player.x.isWithInOneOf(lastBuildingPlaced.x), player.y.isWithInOneOf(lastBuildingPlaced.y) {
					buildNormally()
					Game.stages.builder.stage5LastBuildingPlaced = .init(x: player.x, y: player.y)
				} else {
					MessageBox.message("To build a house, you should only build next to the last building you placed.", speaker: .game)
					return
				}
			} else {
				MessageBox.message("You haven't placed a building?", speaker: .game)
				return
			}
		}
	}

	private func itemTypeToMapTileType(_ itemType: ItemType) -> MapTileType? {
		switch itemType {
			case .door:
				MessageBox.message("This shouldn't have happen", speaker: .game)
				return nil
			case .fence: return .fence
			case .gate: return .gate
			default: return nil
		}
	}

	private func checkDoor(tile: DoorTile) throws(DoorPlaceError) {
		if !(grid[player.y][player.x].type == .plain) {
			throw .noSpace
		}
		if !Game.player.has(item: .door(tile: tile), count: 1) {
			throw DoorPlaceError.noDoor
		}
		if !checkBuildingsNearby() {
			throw DoorPlaceError.noEnoughBuildingsNearby
		}
	}

	private func checkBuildingsNearby() -> Bool {
		let x = player.x
		let y = player.y
		let nearbyTiles = [
			grid[y - 1][x],
			grid[y + 1][x],
			grid[y][x - 1],
			grid[y][x + 1],
		]
		var buildingsNearby = 0
		for tile in nearbyTiles {
			if tile.type == .building(tile: .init(isPlacedByPlayer: true)) {
				buildingsNearby += 1
			}
		}
		// TODO: check if total buildings is enough to make an inside
		return buildingsNearby >= 3
	}
}

enum DoorPlaceError: Error {
	case noDoor
	case noSpace
	case noEnoughBuildingsNearby

	var localizedDescription: String {
		switch self {
			case .noDoor: "You don't have a door to place."
			case .noSpace: "You can only place a door on a plain tile."
			case .noEnoughBuildingsNearby: "Fix"
		}
	}
}

extension Int {
	func isWithInOneOf(_ other: Int) -> Bool {
		self == other || self == other + 1 || self == other - 1
	}
}
