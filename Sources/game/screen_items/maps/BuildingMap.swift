struct BuildingMap {
    var grid: [[Tile]]
    var width: Int
    var height: Int
    
    private var hasUpdatedDims = false
    var player: Player = Player(x: 1, y: 1)
    
    init(_ mapType: MapType) {
        self.grid = StaticMaps.buildingMap(for: StaticMaps.mapTypeToBuilding(mapType: mapType))
        
        self.width = grid[0].count + 1
        self.height = grid.count + 1

        if case .castle(side: let side) = mapType {
            switch side {
                case .top:
                    player.x = 64
                    player.y = 1
                case .bottom:
                    player.x = 65
                    player.y = 53
                case .right:
                    player.x = 129
                    player.y = 27
                case .left:
                    player.x = 1
                    player.y = 27
            }
        } else {
            if let (startX, startY) = Tile.findTilePosition(of: .playerStart, in: grid) {
                player.x = startX
                player.y = startY
            } else {
                print("Error: Could not find playerStart tile in the building grid.")
            }
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
    
    func render(playerX: Int, playerY: Int, viewportWidth: Int, viewportHeight: Int) {
        let halfViewportWidth = viewportWidth / 2
        let halfViewportHeight = viewportHeight / 2
        
        let startX = max(0, playerX - halfViewportWidth)
        let startY = max(0, playerY - halfViewportHeight)
        
        let endX = min(grid[0].count, startX + viewportWidth)
        let endY = min(grid.count, startY + viewportHeight)
        
        for (screenY, mapY) in (startY..<endY).enumerated() {
            var rowString = ""
            for mapX in startX..<endX {
                if mapX == playerX && mapY == playerY {
                    rowString += TileType.player.render
                } else {
                    rowString += grid[mapY][mapX].type.render
                }
            }
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
                TileEvent.trigger(event: event)
            }
        } else {
            MessageBox.message("There is nothing to do here.", speaker: .game)
        }
    }
}
