struct MapGen {
    static let mapWidth = 5000
    static let mapHeight = 5000

    static func generateFullMap() -> [[Tile]] {
        var map: [[Tile]] = Array(repeating: Array(repeating: Tile(type: .TOBEGENERATED), count: mapWidth), count: mapHeight)

        // Step 1: Place static region in the center
        let staticRegion = StaticMaps.MainMap // Load your static map
        let offsetX = staticRegion[0].count // Adjust as per your static map's position
        let offsetY = staticRegion.count
        for y in 0..<staticRegion.count {
            for x in 0..<staticRegion[y].count {
                map[offsetY + y][offsetX + x] = staticRegion[y][x]
            }
        }

        // Step 2: Fill the remaining tiles procedurally
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                if map[y][x] == Tile(type: .TOBEGENERATED) { // Only fill empty tiles
                    if x < mapWidth / 2 && y < mapHeight / 2 {
                        // forest
                    } else if x > mapWidth / 2 && y < mapHeight / 2 {
                        // snow
                    } else if x > mapWidth / 2 && y > mapHeight / 2 {
                        //plains
                    } else if x < mapWidth / 2 && y > mapHeight / 2 {
                        // desert
                    }
                    
                    map[y][x] = Tile(type: .sand) // Function to generate tile type
                }
            }
        }
        return map
    }
}
