import Foundation

struct Game: Codable {
	nonisolated(unsafe) static var config: Config = .init()
	private(set) nonisolated(unsafe) static var hasInited: Bool = false
	private(set) nonisolated(unsafe) static var isTypingInMessageBox: Bool = false
	nonisolated(unsafe) static var player = PlayerCharacter()
	private(set) nonisolated(unsafe) static var map = MapGen.generateFullMap()
	nonisolated(unsafe) static var startingVillageChecks: StartingVillageChecks = .init()
	nonisolated(unsafe) static var stages: Stages = .init()
	nonisolated(unsafe) static var messages: [String] = []
	nonisolated(unsafe) static var mapGen: MapGenSave = .init(amplitude: MapGenSave.defaultAmplitude, frequency: MapGenSave.defaultFrequency, seed: .random(in: 2 ... 1_000_000_000))

	// Don't save
	nonisolated(unsafe) static var isInInventoryBox: Bool = false
	nonisolated(unsafe) static var isBuilding: Bool = false

	//    nonisolated(unsafe) private(set) static var map = MapGen.generateFullMap()

	static func initGame() {
		hasInited = true
		MapBox.mainMap = MainMap()

		let filePath = FileManager.default.homeDirectoryForCurrentUser
		let directory = filePath.appendingPathComponent(".adventure")
		let file = directory.appendingPathComponent(Config.configFile)

		do {
			if !FileManager.default.fileExists(atPath: directory.path) {
				try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
			}

			let data = try JSONDecoder().decode(Config.self, from: Data(contentsOf: file))
			config = data
		} catch {
			print("Error: Could not read config file. Creating a new one.")

			do {
				let data = try JSONEncoder().encode(config)
				try data.write(to: file)
			} catch {
				print("Error: Could not write config file at \(file). \(error)")
				exit(1)
			}
		}
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

struct Config: Codable {
	static let configFile: String = "adventure-config.json"
	var useNerdFont: Bool = true
	var vimKeys: Bool = false
	var arrowKeys: Bool = false
	var wasdKeys: Bool = true
}
