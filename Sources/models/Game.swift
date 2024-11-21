struct Game: Codable {
    nonisolated(unsafe) private(set) static var location: Location = .startVillage
    nonisolated(unsafe) private(set) static var hasInited: Bool = false
    nonisolated(unsafe) private(set) static var isTypingInMessageBox: Bool = false
    nonisolated(unsafe) static var player = PlayerCharacter()
    nonisolated(unsafe) private(set) static var map = StaticMaps.MainMap
    nonisolated(unsafe) static var startingVillageChecks: StartingVillageChecks = StartingVillageChecks()
    nonisolated(unsafe) static var stages: Stages = Stages()
    nonisolated(unsafe) static var messages: [String] = []
    
//    nonisolated(unsafe) private(set) static var map = MapGen.generateFullMap()
    
    static func initGame() {
        Self.hasInited = true
        MapBox.gameMap = GameMap(location: .startVillage)
    }
    static func changeLocation(to location: Location) {
        Self.location = location
        MapBox.gameMap = GameMap(location: location)
    }
    static func setIsTypingInMessageBox(_ newIsTypingInMessageBox: Bool) {
        Self.isTypingInMessageBox = newIsTypingInMessageBox
    }
    static func reloadGame(decodedGame: CodableGame) {
        self.location = decodedGame.location
        self.hasInited = decodedGame.hasInited
        self.isTypingInMessageBox = decodedGame.isTypingInMessageBox
        self.player = decodedGame.player
        self.map = decodedGame.map
        self.startingVillageChecks = decodedGame.startingVillageChecks
        self.stages = decodedGame.stages
        self.messages = decodedGame.messages
    }
}

struct CodableGame: Codable {
    var location: Location
    var hasInited: Bool
    var isTypingInMessageBox: Bool
    var player: PlayerCharacter
    var map: [[Tile]]
    var startingVillageChecks: StartingVillageChecks
    var stages: Stages
    var messages: [String]
}

enum Location: Codable {
    case startVillage
}
