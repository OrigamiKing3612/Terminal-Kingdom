struct ChopTreeEvent {
    static func chopTree() {
        
        //TODO: get seed need pot then plant half grown tree?
        MessageBox.message("Timber!", speaker: .game)
        let x = MapBox.player.x
        let y = MapBox.player.y
        if MapBox.mainMap.grid[y][x].type == .tree {
            MapBox.mainMap.grid[y][x] = MapTile(type: .plain)
            
            let lumberCount = Int.random(in: 1...3)
            Game.player.collect(item: .lumber, count: lumberCount)
        }
    }
}
