enum ChopTreeEvent {
	static func chopTree() {
		// TODO: get seed need pot then plant half grown tree?
		MessageBox.message("Timber!", speaker: .game)
		let x = MapBox.player.x
		let y = MapBox.player.y
		if MapBox.mainMap.grid[y][x].type == .tree {
			MapBox.mainMap.grid[y][x] = MapTile(type: .plain)

			let lumberCount = Int.random(in: 1 ... 3)
			_ = Game.player.collect(item: .init(type: .lumber), count: lumberCount)
			Game.player.removeDurability(of: .axe)
		}
	}
}
