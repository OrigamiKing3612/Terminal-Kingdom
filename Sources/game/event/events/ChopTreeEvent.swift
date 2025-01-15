enum ChopTreeEvent {
	static func chopTree() {
		MessageBox.message("Timber!", speaker: .game)
		let x = MapBox.player.x
		let y = MapBox.player.y
		if MapBox.mainMap.grid[y][x].type == .tree {
			MapBox.mainMap.grid[y][x] = MapTile(type: .plain)

			let lumberCount = Int.random(in: 1 ... 3)
			let seedCount = Int.random(in: 1 ... 3)
			_ = Game.player.collect(item: .init(type: .lumber), count: lumberCount)
			_ = Game.player.collect(item: .init(type: .tree_seed), count: seedCount)
			Game.player.removeDurability(of: .axe)
		}
	}
}
