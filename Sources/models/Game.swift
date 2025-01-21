import Foundation

struct Game: Codable {
	static let version = "0.0.1-alpha_1"
	nonisolated(unsafe) static var config: Config = .init()
	nonisolated(unsafe) static var player = PlayerCharacter()
	nonisolated(unsafe) static var startingVillageChecks: StartingVillageChecks = .init()
	nonisolated(unsafe) static var stages: Stages = .init()
	nonisolated(unsafe) static var messages: [String] = []
	nonisolated(unsafe) static var mapGen: MapGenSave = .init(amplitude: MapGenSave.defaultAmplitude, frequency: MapGenSave.defaultFrequency, seed: .random(in: 2 ... 1_000_000_000))
	private(set) nonisolated(unsafe) static var hasInited: Bool = false
	private(set) nonisolated(unsafe) static var isTypingInMessageBox: Bool = false
	private(set) nonisolated(unsafe) static var map = MapGen.generateFullMap()
	private(set) nonisolated(unsafe) static var customMaps: [CustomMap] = []

	// Don't save
	nonisolated(unsafe) static var isInInventoryBox: Bool = false
	nonisolated(unsafe) static var isBuilding: Bool = false
	nonisolated(unsafe) static var horizontalLine: String { config.useNerdFont ? "─" : "=" }
	nonisolated(unsafe) static var verticalLine: String { config.useNerdFont ? "│" : "|" }

	//    nonisolated(unsafe) private(set) static var map = MapGen.generateFullMap()

	static func initGame() {
		hasInited = true
		MapBox.mainMap = MainMap()
		config = Config.load()
	}

	static func setIsTypingInMessageBox(_ newIsTypingInMessageBox: Bool) {
		isTypingInMessageBox = newIsTypingInMessageBox
	}

	static func reloadGame(decodedGame: CodableGame) {
		hasInited = decodedGame.hasInited
		isTypingInMessageBox = decodedGame.isTypingInMessageBox
		player = decodedGame.player
		map = decodedGame.map
		startingVillageChecks = decodedGame.startingVillageChecks
		stages = decodedGame.stages
		messages = decodedGame.messages
		mapGen = decodedGame.mapGen
	}

	static func addMap(map: CustomMap) {
		customMaps.append(map)
	}

	static func removeMap(map: CustomMap) {
		customMaps.removeAll(where: { $0.id == map.id })
	}

	static func removeMap(mapID: UUID) {
		customMaps.removeAll(where: { $0.id == mapID })
	}
}

// TODO: remove because Game is codable
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
