import Foundation

struct Game: Codable {
    nonisolated(unsafe) static var config: Config = Config()
    nonisolated(unsafe) private(set) static var hasInited: Bool = false
    nonisolated(unsafe) private(set) static var isTypingInMessageBox: Bool = false
    nonisolated(unsafe) static var player = PlayerCharacter()
    nonisolated(unsafe) private(set) static var map = MapGen.generateFullMap()
    nonisolated(unsafe) static var startingVillageChecks: StartingVillageChecks = .init()
    nonisolated(unsafe) static var stages: Stages = Stages()
    nonisolated(unsafe) static var messages: [String] = []
    nonisolated(unsafe) static var mapGen: MapGenSave = .init(amplitude: MapGenSave.defaultAmplitude, frequency: MapGenSave.defaultFrequency, seed: .random(in: 2...1000000000))

    //    nonisolated(unsafe) private(set) static var map = MapGen.generateFullMap()

    static func initGame() {
        Self.hasInited = true
        MapBox.mainMap = MainMap()


        let filePath = FileManager.default.homeDirectoryForCurrentUser
        let directory = filePath.appendingPathComponent(".adventure")
        let file = directory.appendingPathComponent(Config.configFile)

        do {
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            }

            let data = try JSONDecoder().decode(Config.self, from: Data(contentsOf: file))
            self.config = data
        } catch {
            print("Error: Could not read config file. Creating a new one.")

            do {
                let data = try JSONEncoder().encode(self.config)
                try data.write(to: file)
            } catch {
                print("Error: Could not write config file at \(file). \(error)")
                exit(1)
            }
        }
    }

    static func setIsTypingInMessageBox(_ newIsTypingInMessageBox: Bool) {
        Self.isTypingInMessageBox = newIsTypingInMessageBox
    }
    static func reloadGame(decodedGame: CodableGame) {
        self.hasInited = decodedGame.hasInited
        self.isTypingInMessageBox = decodedGame.isTypingInMessageBox
        self.player = decodedGame.player
        self.map = decodedGame.map
        self.startingVillageChecks = decodedGame.startingVillageChecks
        self.stages = decodedGame.stages
        self.messages = decodedGame.messages
        self.mapGen = decodedGame.mapGen
    }
}

//TODO: remove because Game is codable
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
    var vimKeys: Bool = false
    var arrowKeys: Bool = false
    var wasdKeys: Bool = true
}
