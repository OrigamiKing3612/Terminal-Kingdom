import Foundation

actor Game {
	static var shared = Game()
	nonisolated static let version = "0.0.1-alpha_1"
	var config: Config = .init()
	var player = PlayerCharacter()
	var startingVillageChecks: StartingVillageChecks = .init()
	var stages: Stages = .init()
	var mapGen: MapGen = .init()
	var maps: Maps = .init()
	private(set) var messages: [String] = []
	private(set) var crops: Set<TilePosition> = []
	private(set) var npcs: Set<NPCPosition> = []
	private(set) var hasInited: Bool = false
	private(set) var isTypingInMessageBox: Bool = false
	private(set) var map: [[MapTile]] = []
	private(set) var hasStartedCropQueue: Bool = false
	private(set) var hasStartedNPCQueue: Bool = false
	// Don't save
	private(set) var isInInventoryBox: Bool = false
	private(set) var isBuilding: Bool = false
	var horizontalLine: String { config.useNerdFont ? "─" : "=" }
	var verticalLine: String { config.useNerdFont ? "│" : "|" }

	//     private(set) var map = MapGen.generateFullMap()

	private init() {}

	func initGame() async {
		hasInited = true
		map = await mapGen.generateFullMap()
		config = await Config.load()
	}

	func setIsTypingInMessageBox(_ newIsTypingInMessageBox: Bool) async {
		isTypingInMessageBox = newIsTypingInMessageBox
	}

	// func reloadGame(decodedGame: CodableGame) async {
	// 	hasInited = decodedGame.hasInited
	// 	isTypingInMessageBox = decodedGame.isTypingInMessageBox
	// 	// player = decodedGame.player
	// 	map = decodedGame.map
	// 	startingVillageChecks = decodedGame.startingVillageChecks
	// 	stages = decodedGame.stages
	// 	messages = decodedGame.messages
	// 	mapGen = decodedGame.mapGen
	// }

	func addMessage(_ message: String) async {
		messages.append(message)
	}

	func removeMessage(at index: Int) async {
		messages.remove(at: index)
	}

	func addCrop(_ position: TilePosition) async {
		// TODO: cancel the crop queue if crops is empty and remove a crop position if it is fully grown
		if !hasStartedCropQueue {
			await startCropQueue()
			hasStartedCropQueue = true
		}
		crops.insert(position)
	}

	func removeCrop(_ position: TilePosition) async {
		crops.remove(position)
	}

	func addNPC(_ position: NPCPosition) async {
		// TODO: cancel the crop queue if crops is empty and remove a crop position if it is fully grown
		if !hasStartedNPCQueue {
			await startNPCMovingQueue()
			hasStartedNPCQueue = true
		}
		npcs.insert(position)
	}

	func updateNPC(oldPosition: NPCPosition, newPosition: NPCPosition) async {
		npcs.remove(oldPosition)
		await addNPC(newPosition)
	}

	func removeNPC(_ position: NPCPosition) async {
		npcs.remove(position)
	}

	func setIsInInventoryBox(_ newIsInInventoryBox: Bool) async {
		isInInventoryBox = newIsInInventoryBox
	}

	func setIsBuilding(_ newIsBuilding: Bool) async {
		isBuilding = newIsBuilding
	}

	func addMap(map: CustomMap) async {
		await maps.addMap(map: map)
	}

	func removeMap(map: CustomMap) async {
		await maps.removeMap(map: map)
	}

	func removeMap(mapID: UUID) async {
		await maps.removeMap(mapID: mapID)
	}

	@discardableResult
	func messagesRemoveLast() async -> String {
		messages.removeLast()
	}

	func setHasBeenTaughtToChopLumber(_ newHasBeenTaughtToChopLumber: StartingVillageChecksStages) async {
		await startingVillageChecks.setHasBeenTaughtToChopLumber(newHasBeenTaughtToChopLumber)
	}

	func setHasUsedMessageWithOptions(_ newHasUsedMessageWithOptions: Bool) async {
		await startingVillageChecks.setHasUsedMessageWithOptions(newHasUsedMessageWithOptions)
	}

	func loadConfig() async {
		config = await Config.load()
	}

	func getBiome(x: Int, y: Int) async -> BiomeType {
		await mapGen.getBiome(x: x, y: y)
	}

	func getBiomeAtPlayerPosition() async -> BiomeType {
		await mapGen.getBiomeAtPlayerPosition()
	}
}

// TODO: update because Game is not codable
// struct CodableGame: Codable {
// 	var hasInited: Bool
// 	var isTypingInMessageBox: Bool
// 	var player: PlayerCharacterCodable
// 	var map: [[MapTile]]
// 	var startingVillageChecks: StartingVillageChecks
// 	var stages: Stages
// 	var messages: [String]
// 	var mapGen: MapGenSave
// }

struct TilePosition: Codable, Hashable {
	var x: Int
	var y: Int
	var mapType: MapType
}

struct NPCPosition: Codable, Hashable {
	var x: Int
	var y: Int
	var mapType: MapType
	var oldTile: MapTile
}
