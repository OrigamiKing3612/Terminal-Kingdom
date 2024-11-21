struct MapBox {
    nonisolated(unsafe) static var player: Player {
        get {
            Game.player.position
        }
        set {
            Game.player.updatePlayerPositionToSave(x: newValue.x, y: newValue.y)
        }
    }
    nonisolated(unsafe) static var minePlayer: Player = Player(x: 1, y: 1)
    nonisolated(unsafe) static var gameMap: GameMap = GameMap(location: .startVillage)
    nonisolated(unsafe) static var mineMap: MineMap = MineMap()
    private nonisolated(unsafe) static var hasUpdatedDims = false
    nonisolated(unsafe) static var showMapBox = true {
        didSet {
            if showMapBox {
                mapBox()
            } else {
                clear()
            }
        }
    }
    
    nonisolated(unsafe) static var mapType: MapType = .map {
        didSet {
            if mapType == .mine {
                mineMap = .init()
            }
            mapBox()
        }
    }
    
    static var tilePlayerIsOn: Tile {
        gameMap.grid[player.y][player.x]
    }
    
    static let q1StartX = (Screen.columns / 2)
    static let q1EndX = Screen.columns
    static var q1Width: Int {
        abs((Screen.columns / 2) - 3)
    }
    
    static let q1StartY = 1
    static let q1EndY = Screen.rows / 2
    static var q1Height: Int {
        abs((Screen.rows / 2) - 2)
    }
    
    static func mapBox() {
        clear()
        
        Screen.print(x: q1StartX, y: q1StartY, String(repeating: "=", count: q1Width + 3))
        for y in (q1StartY + 1)..<q1EndY {
            Screen.print(x: q1StartX, y: y, "|")
            Screen.print(x: q1EndX - 1, y: y, "|")
        }
        Screen.print(x: q1StartX, y: q1EndY, String(repeating: "=", count: q1Width + 3))
        
        switch mapType {
            case .map:
                if !hasUpdatedDims {
                    gameMap.updateDimensions(width: q1Width, height: q1Height)
                    if let (startX, startY) = Tile.findTilePosition(of: .playerStart, in: gameMap.grid) {
                        player.x = startX
                        player.y = startY
                    } else {
                        print("Error: Could not find playerStart tile in the grid.")
                    }
                    hasUpdatedDims = true
                }
                
                let viewportWidth = q1Width + 1
                let viewportHeight = q1Height
                gameMap.render(playerX: player.x, playerY: player.y, viewportWidth: viewportWidth, viewportHeight: viewportHeight)
            case .mine:
                if !hasUpdatedDims {
                    mineMap.updateDimensions(width: q1Width, height: q1Height)
                    hasUpdatedDims = true
                }
                
                let viewportWidth = q1Width + 1
                let viewportHeight = q1Height
                mineMap.render(playerX: minePlayer.x, playerY: minePlayer.y, viewportWidth: viewportWidth, viewportHeight: viewportHeight)
        }
    }
    
    static func clear() {
        let spaceString = String(repeating: " ", count: q1Width + 1)
        for y in (q1StartY + 1)..<q1EndY {
            Screen.print(x: q1StartX + 1, y: y, spaceString)
        }
    }
    static func movePlayer(_ direction: Direction) {
        switch mapType {
            case .map:
                let oldX = player.x
                let oldY = player.y
                
                switch direction {
                    case .up where gameMap.isWalkable(x: player.x, y: player.y - 1):
                        player.y -= 1
                    case .down where gameMap.isWalkable(x: player.x, y: player.y + 1):
                        player.y += 1
                    case .left where gameMap.isWalkable(x: player.x - 1, y: player.y):
                        player.x -= 1
                    case .right where gameMap.isWalkable(x: player.x + 1, y: player.y):
                        player.x += 1
                    default:
                        break
                }
                
                if oldX != player.x || oldY != player.y {
                    mapBox()
                }
            case .mine:
                let oldX = minePlayer.x
                let oldY = minePlayer.y
                
                switch direction {
                    case .up where mineMap.isWalkable(x: minePlayer.x, y: minePlayer.y - 1):
                        minePlayer.y -= 1
                    case .down where mineMap.isWalkable(x: minePlayer.x, y: minePlayer.y + 1):
                        minePlayer.y += 1
                    case .left where mineMap.isWalkable(x: minePlayer.x - 1, y: minePlayer.y):
                        minePlayer.x -= 1
                    case .right where mineMap.isWalkable(x: minePlayer.x + 1, y: minePlayer.y):
                        minePlayer.x += 1
                    // mine
                    case .up where !mineMap.isWalkable(x: minePlayer.x, y: minePlayer.y - 1) && Game.player.hasPickaxe():
                        MineMap.givePlayerTile(tile: mineMap.grid[minePlayer.y - 1][minePlayer.x])
                        mineMap.grid[minePlayer.y - 1][minePlayer.x] = .init(type: .plain, isWalkable: true)
                        Game.player.removeDurability(of: .pickaxe())
                        minePlayer.y -= 1
                    case .down where !mineMap.isWalkable(x: minePlayer.x, y: minePlayer.y + 1) && Game.player.hasPickaxe():
                        MineMap.givePlayerTile(tile: mineMap.grid[minePlayer.y + 1][minePlayer.x])
                        mineMap.grid[minePlayer.y + 1][minePlayer.x] = .init(type: .plain, isWalkable: true)
                        Game.player.removeDurability(of: .pickaxe())
                        minePlayer.y += 1
                    case .left where !mineMap.isWalkable(x: minePlayer.x - 1, y: minePlayer.y) && Game.player.hasPickaxe():
                        MineMap.givePlayerTile(tile: mineMap.grid[minePlayer.y][minePlayer.x - 1])
                        mineMap.grid[minePlayer.y][minePlayer.x - 1] = .init(type: .plain, isWalkable: true)
                        Game.player.removeDurability(of: .pickaxe())
                        minePlayer.x -= 1
                    case .right where !mineMap.isWalkable(x: minePlayer.x + 1, y: minePlayer.y) && Game.player.hasPickaxe():
                        MineMap.givePlayerTile(tile: mineMap.grid[minePlayer.y][minePlayer.x + 1])
                        mineMap.grid[minePlayer.y][minePlayer.x + 1] = .init(type: .plain, isWalkable: true)
                        Game.player.removeDurability(of: .pickaxe())
                        minePlayer.x += 1
                    default:
                        break
                }
                
                if oldX != minePlayer.x || oldY != minePlayer.y {
                    mapBox()
                }
        }
    }
    static func interactWithTile() {
        switch mapType {
            case .map:
                let tile = gameMap.grid[player.y][player.x]
                if tile.isInteractable {
                    if let event = tile.event {
                        TileEvent.trigger(event: event)
                    }
                } else {
                    MessageBox.message("There is nothing to do here.", speaker: .game)
                }
            case .mine:
                let tile = mineMap.grid[minePlayer.y][minePlayer.x]
                if tile.isInteractable {
                    if let event = tile.event {
                        MineTileEvent.trigger(event: event)
                    }
                } else {
                    MessageBox.message("There is nothing to do here.", speaker: .game)
                }
        }
    }
}

enum MapType {
    case map, mine
}

enum Direction {
    case up, down, left, right
}

struct Player: Codable {
    var x: Int
    var y: Int
}

struct GameMap {
    var grid: [[Tile]]
    var width: Int
    var height: Int
    var location: Location
    
    init(location: Location) {
        self.grid = Game.map
        self.location = location
        self.width = grid[0].count + 1
        self.height = grid.count + 1
    }
    
    mutating func updateDimensions(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    func isWalkable(x: Int, y: Int) -> Bool {
        guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
        return grid[y][x].isWalkable
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
                    rowString += TileType.player.render
                } else {
                    rowString += grid[mapY][mapX].type.render
                }
            }
            // Print each row to the screen at the appropriate position
            Screen.print(x: MapBox.q1StartX + 1, y: MapBox.q1StartY + 1 + screenY, rowString)
        }
    }
}

struct MineMap {
    var grid: [[MineTile]]
    var width: Int
    var height: Int
    
    init() {
        self.grid = Array(repeating: [], count: 2 * MapBox.q1Height).map { _ in
            (0..<(2 * MapBox.q1Width)).map { _ in
                let randomValue = Int.random(in: 1...100)
                let tileType: MineTileType
                if randomValue <= 70 {
                    tileType = .stone
                } else if randomValue <= 85 { // 100% - 20%
                    tileType = .coal
                } else {
                    tileType = .iron
                }
                return MineTile(type: tileType)
            }
        }
        self.width = grid[0].count + 1
        self.height = grid.count + 1
        
        let middleX = self.grid[0].count / 2
//        let middleY = self.grid.count / 2
        
        self.grid[0][middleX] = .init(type: .playerStart, isWalkable: true)
        self.grid[0][middleX + 1] = .init(type: .plain, isWalkable: true)
        self.grid[0][middleX - 1] = .init(type: .plain, isWalkable: true)
        
        if let (startX, startY) = MineTile.findTilePosition(of: .playerStart, in: grid) {
            MapBox.minePlayer.x = startX
            MapBox.minePlayer.y = startY
        } else {
            print("Error: Could not find playerStart tile in the mine grid.")
        }
    }
    
    mutating func updateDimensions(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    func isWalkable(x: Int, y: Int) -> Bool {
        guard x >= 0, y >= 0, y < grid.count, x < grid[y].count else { return false }
        return grid[y][x].isWalkable
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
                    rowString += MineTileType.player.render(tile: grid[mapY][mapX], tileX: mapX, tileY: mapY)
                } else {
                    rowString += grid[mapY][mapX].type.render(tile: grid[mapY][mapX], tileX: mapX, tileY: mapY)
                }
            }
            // Print each row to the screen at the appropriate position
            Screen.print(x: MapBox.q1StartX + 1, y: MapBox.q1StartY + 1 + screenY, rowString)
        }
    }
    static func givePlayerTile(tile: MineTile) {
        var itemToGive: Item?
        switch tile.type {
            case .coal: itemToGive = .coal
            case .iron: itemToGive = .iron
            case .stone: itemToGive = .stone
            default: break
        }
        if let itemToGive {
            Game.player.collect(item: itemToGive)
        }
    }
}
