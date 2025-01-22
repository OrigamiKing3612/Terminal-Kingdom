import Foundation

// TODO: remove static because that undoes the point of the actor
actor Game {
	nonisolated static let version = "0.0.1-alpha_1"
	static var config: Config = .init()
	static var player = PlayerCharacter()
	static var startingVillageChecks: StartingVillageChecks = .init()
	static var stages: Stages = .init()
	static var messages: [String] = []
	static var mapGen: MapGenSave = .init(amplitude: MapGenSave.defaultAmplitude, frequency: MapGenSave.defaultFrequency, seed: .random(in: 2 ... 1_000_000_000))
	static var crops: Set<TilePosition> = []
	private(set) static var hasInited: Bool = false
	private(set) static var isTypingInMessageBox: Bool = false
	private(set) static var map = MapGen.generateFullMap()
	private(set) static var customMaps: [CustomMap] = []

	// Don't save
	static var isInInventoryBox: Bool = false
	static var isBuilding: Bool = false
	static var horizontalLine: String { config.useNerdFont ? "─" : "=" }
	static var verticalLine: String { config.useNerdFont ? "│" : "|" }

	//     private(set) static var map = MapGen.generateFullMap()

	static func initGame() async {
		hasInited = true
		MapBox.mainMap = MainMap()
		config = Config.load()
	}

	static func setIsTypingInMessageBox(_ newIsTypingInMessageBox: Bool) async {
		isTypingInMessageBox = newIsTypingInMessageBox
	}

	static func reloadGame(decodedGame: CodableGame) async {
		hasInited = decodedGame.hasInited
		isTypingInMessageBox = decodedGame.isTypingInMessageBox
		player = decodedGame.player
		map = decodedGame.map
		startingVillageChecks = decodedGame.startingVillageChecks
		stages = decodedGame.stages
		messages = decodedGame.messages
		mapGen = decodedGame.mapGen
	}

	static func addMap(map: CustomMap) async {
		customMaps.append(map)
	}

	static func removeMap(map: CustomMap) async {
		customMaps.removeAll(where: { $0.id == map.id })
	}

	static func removeMap(mapID: UUID) async {
		customMaps.removeAll(where: { $0.id == mapID })
	}
}

// TODO: update because Game is not codable
struct CodableGame: Codable {
	var hasInited: Bool
	var isTypingInMessageBox: Bool
	var player: PlayerCharacter
	var map: [[MapTile]]
	var startingVillageChecks: StartingVillageChecks
	var stages: Stages
	var messages: [String]
	var mapGen: MapGenSave
}

struct TilePosition: Codable, Hashable {
	var x: Int
	var y: Int
}
