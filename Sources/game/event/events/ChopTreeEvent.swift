struct ChopTreeEvent {
    static func chopTree() {
        
        //TODO: get seed need pot then plant half grown tree?
        MessageBox.message("Timber!", speaker: .game)
        let x = MapBox.player.x
        let y = MapBox.player.y
        if MapBox.gameMap.grid[y][x].type == .tree {
            MapBox.gameMap.grid[y][x] = Tile(type: .plain)
            
            let lumberCount = Int.random(in: 1...3)
            Game.player.collect(item: .lumber, count: lumberCount)
        }
    }
}
