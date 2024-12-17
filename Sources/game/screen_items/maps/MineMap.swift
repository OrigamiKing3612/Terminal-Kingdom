struct MineMap: MapBoxMap {
    var grid: [[MineTile]]
    var width: Int
    var height: Int

    private var hasUpdatedDims = false
    var player: Player = Player(x: 1, y: 1)

    var tilePlayerIsOn: MineTile {
        grid[player.y][player.x]
    }

    init() {
        self.grid = MineMap.createGrid()
        self.width = grid[0].count + 1
        self.height = grid.count + 1

        let middleX = self.grid[0].count / 2
        //        let middleY = self.grid.count / 2

        self.grid[0][middleX] = .init(type: .playerStart, isWalkable: true)
        self.grid[0][middleX + 1] = .init(type: .plain, isWalkable: true)
        self.grid[0][middleX - 1] = .init(type: .plain, isWalkable: true)

        if let (startX, startY) = MineTile.findTilePosition(of: .playerStart, in: grid) {
            player.x = startX
            player.y = startY
        } else {
            print("Error: Could not find playerStart tile in the mine grid.")
        }
    }

    mutating func map() {
        if !hasUpdatedDims {
            self.updateDimensions(width: MapBox.q1Width, height: MapBox.q1Height)
            hasUpdatedDims = true
        }

        let viewportWidth = MapBox.q1Width + 1
        let viewportHeight = MapBox.q1Height
        self.render(playerX: player.x, playerY: player.y, viewportWidth: viewportWidth, viewportHeight: viewportHeight)
    }

    mutating func updateDimensions(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    func isWalkable(x: Int, y: Int) -> Bool {
        guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
        return grid[y][x].isWalkable
    }

    func isInBounds(x: Int, y: Int) -> Bool {
        guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
        return true
    }

    func render(playerX: Int, playerY: Int, viewportWidth: Int, viewportHeight: Int) {
        // Calculate viewport bounds relative to the player's position
        let halfViewportWidth = viewportWidth / 2
        let halfViewportHeight = viewportHeight / 2

        let startX = max(0, playerX - halfViewportWidth)
        let startY = max(0, playerY - halfViewportHeight)

        let endX = min(grid[0].count, startX + viewportWidth)
        let endY = min(grid.count, startY + viewportHeight)

        // Iterate through the viewport and render each tile
        for (screenY, mapY) in (startY..<endY).enumerated() {
            var rowString = ""
            for mapX in startX..<endX {
                if mapX == playerX && mapY == playerY {
                    rowString += MineTileType.player.render(grid: grid, tileX: mapX, tileY: mapY)
                } else {
                    rowString += grid[mapY][mapX].type.render(grid: grid, tileX: mapX, tileY: mapY)
                }
            }
            // Print each row to the screen at the appropriate position
            Screen.print(x: MapBox.q1StartX + 1, y: MapBox.q1StartY + 1 + screenY, rowString)
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
                // mine
            case .up where !grid[player.y - 1][player.x].isWalkable && Game.player.hasPickaxe() && isInBounds(x: player.x, y: player.y):
                MineMap.givePlayerTile(tile: grid[player.y - 1][player.x])
                grid[player.y - 1][player.x] = .init(type: .plain, isWalkable: true)
                Game.player.removeDurability(of: .pickaxe())
                player.y -= 1
            case .down where !grid[player.y + 1][player.x].isWalkable && Game.player.hasPickaxe() && isInBounds(x: player.x, y: player.y):
                MineMap.givePlayerTile(tile: grid[player.y + 1][player.x])
                grid[player.y + 1][player.x] = .init(type: .plain, isWalkable: true)
                Game.player.removeDurability(of: .pickaxe())
                player.y += 1
            case .left where !grid[player.y][player.x - 1].isWalkable && Game.player.hasPickaxe() && isInBounds(x: player.x, y: player.y):
                MineMap.givePlayerTile(tile: grid[player.y][player.x - 1])
                grid[player.y][player.x - 1] = .init(type: .plain, isWalkable: true)
                Game.player.removeDurability(of: .pickaxe())
                player.x -= 1
            case .right where !grid[player.y][player.x + 1].isWalkable && Game.player.hasPickaxe() && isInBounds(x: player.x, y: player.y):
                MineMap.givePlayerTile(tile: grid[player.y][player.x + 1])
                grid[player.y][player.x + 1] = .init(type: .plain, isWalkable: true)
                Game.player.removeDurability(of: .pickaxe())
                player.x += 1
            default:
                break
        }

        if oldX != player.x || oldY != player.y {
            map()
        }
    }
    func interactWithTile() {
        let tile = grid[player.y][player.x]
        if tile.isInteractable {
            if let event = tile.event {
                MineTileEvent.trigger(event: event)
            }
        } else {
            MessageBox.message("There is nothing to do here.", speaker: .game)
        }
    }
    static func givePlayerTile(tile: MineTile) {
        var itemTypeToGive: ItemType?
        switch tile.type {
            case .coal: itemTypeToGive = .coal
            case .iron: itemTypeToGive = .iron
            case .stone: itemTypeToGive = .stone
            case .clay: itemTypeToGive = .clay
            default: break
        }
        if let itemTypeToGive {
            Game.player.collect(item: .init(type: itemTypeToGive))
        }
    }
    static func createGrid() -> [[MineTile]] {
        switch Game.player.stats.mineLevel {
            case .one:
                return MineMapLevelGrids.createGridLevel1()
            case .two:
                return MineMapLevelGrids.createGridLevel2()
        }
    }
}

struct MineMapLevelGrids {
    static func createGridLevel1() -> [[MineTile]] {
        return Array(repeating: [], count: 2 * MapBox.q1Height).map { _ in
            (0..<(2 * MapBox.q1Width)).map { _ in
                let randomValue = Int.random(in: 1...100)
                let tileType: MineTileType
                if randomValue <= 85 {
                    tileType = .clay
                } else {
                    tileType = .stone
                }
                return MineTile(type: tileType)
            }
        }
    }
    static func createGridLevel2() -> [[MineTile]] {
        return Array(repeating: [], count: 2 * MapBox.q1Height).map { _ in
            (0..<(2 * MapBox.q1Width)).map { _ in
                let randomValue = Int.random(in: 1...100)
                let tileType: MineTileType
                if randomValue <= 20 {
                    tileType = .clay
                } else if randomValue <= 70 {
                    tileType = .stone
                } else if randomValue <= 85 {
                    tileType = .coal
                } else {
                    tileType = .iron
                }
                return MineTile(type: tileType)
            }
        }

    }
}
