protocol MapBoxMap {
	associatedtype pTile: Tile
	var grid: [[pTile]] { get set }

	var player: Player { get }
	var tilePlayerIsOn: pTile { get }
	func isWalkable(x: Int, y: Int) async -> Bool
	func render(playerX: Int, playerY: Int, viewportWidth: Int, viewportHeight: Int) async
	func interactWithTile() async

	mutating func movePlayer(_ direction: PlayerDirection) async
	mutating func map() async
}
