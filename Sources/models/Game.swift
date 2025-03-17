import Foundation

actor Game {
	static var shared = Game()
	nonisolated static let version = "0.0.1-alpha_3"
	var config: Config = .init()
	var player = PlayerCharacter()
	var startingVillageChecks: StartingVillageChecks = .init()
	var stages: Stages = .init()
	var mapGen: MapGen = .init()
	var maps: Maps = .init()
	private(set) var kingdoms: [Kingdom] = []
	private(set) var messages: [String] = []
	private(set) var crops: Set<TilePosition> = []
	private(set) var movingNpcs: Set<NPCPosition> = [] {
		didSet {} // TODO: for some reason this is fixing where the NPCs are not moving
	}

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
		movingNpcs.insert(position)
	}

	func updateNPC(oldPosition: NPCPosition, newPosition: NPCPosition) async {
		movingNpcs.remove(oldPosition)
		await addNPC(newPosition)
	}

	func removeNPC(_ position: NPCPosition) async {
		movingNpcs.remove(position)
	}

	func setHasStartedNPCMovingQueue(_ newHasStartedNPCMovingQueue: Bool) async {
		hasStartedNPCQueue = newHasStartedNPCMovingQueue
	}

	func setHasStartedCropQueue(_ newHasStartedCropQueue: Bool) async {
		hasStartedCropQueue = newHasStartedCropQueue
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

	func createKingdom(_ kingdom: Kingdom) async {
		kingdoms.append(kingdom)
	}

	func removeKingdom(_ kingdom: Kingdom) async {
		kingdoms.removeAll(where: { $0.id == kingdom.id })
	}

	func removeKingdom(id: UUID) async {
		kingdoms.removeAll(where: { $0.id == id })
	}

	func addKingdomBuilding(_ building: Building, kingdomID: UUID) async {
		if let index = kingdoms.firstIndex(where: { $0.id == kingdomID }) {
			kingdoms[index].buildings.append(building)
		}
	}

	func addKingdomNPC(_ uuid: UUID, kingdomID: UUID) async {
		if let index = kingdoms.firstIndex(where: { $0.id == kingdomID }) {
			kingdoms[index].npcsInKindom.append(uuid)
		}
	}

	func addKingdomData(_ data: KingdomData, npcInKindom: UUID) async {
		if let index = kingdoms.firstIndex(where: { $0.npcsInKindom.contains(npcInKindom) }) {
			kingdoms[index].data.append(data)
		}
	}

	func removeKingdomData(_ data: KingdomData, npcInKindom: UUID) async {
		if let index = kingdoms.firstIndex(where: { $0.npcsInKindom.contains(npcInKindom) }) {
			kingdoms[index].data.removeAll(where: { $0 == data })
		}
	}

	func setKingdomCastle(kingdomID: UUID) async {
		if let index = kingdoms.firstIndex(where: { $0.id == kingdomID }) {
			kingdoms[index].setHasCastle()
		}
	}

	func removeKingdomCastle(kingdomID: UUID) async {
		if let index = kingdoms.firstIndex(where: { $0.id == kingdomID }) {
			kingdoms[index].removeCastle()
		}
	}

	func getKingdomCastle(kingdomID: UUID) async -> Building? {
		if let index = kingdoms.firstIndex(where: { $0.id == kingdomID }) {
			return kingdoms[index].getCastle()
		}
		return nil
	}

	func isInsideKingdom(x: Int, y: Int) async -> UUID? {
		for kingdom in kingdoms {
			if kingdom.hasCastle {
				let building = kingdom.getCastle()
				if let building {
					let radius = kingdom.radius
					let dx = x - building.x
					let dy = y - building.y

					let distanceSquared = dx * dx + dy * dy
					let radiusSquared = radius * radius

					if distanceSquared <= radiusSquared {
						return kingdom.id
					}
				}
			} else {
				let building = kingdom.buildings.first { $0.type == .builder }
				if let building {
					let radius = kingdom.radius
					let dx = x - building.x
					let dy = y - building.y

					let distanceSquared = dx * dx + dy * dy
					let radiusSquared = radius * radius

					if distanceSquared <= radiusSquared {
						return kingdom.id
					}
				}
			}
		}
		return nil
	}

	func getKingdom(id: UUID) async -> Kingdom? {
		if let index = kingdoms.firstIndex(where: { $0.id == id }) {
			return kingdoms[index]
		}
		return nil
	}

	func getKingdomNPCBuilding(_: UUID, npcInBuilding: UUID) async -> Building? {
		if let index = kingdoms.firstIndex(where: { $0.npcsInKindom.contains(npcInBuilding) }) { // must be in the kingdom
			if let buildingIndex = kingdoms[index].buildings.firstIndex(where: { $0.id == npcInBuilding }) {
				return kingdoms[index].buildings[buildingIndex]
			}
		}
		return nil
	}

	func hasKingdomBuilding(x: Int, y: Int) async -> Building? {
		for kingdom in kingdoms {
			for building in kingdom.buildings {
				if building.x == x, building.y == y {
					return building
				}
			}
		}
		return nil
	}

	func updateKingdomBuilding(kingdomID: UUID, buildingID: UUID, newBuilding: Building) async {
		if let index = kingdoms.firstIndex(where: { $0.id == kingdomID }) {
			if let buildingIndex = kingdoms[index].buildings.firstIndex(where: { $0.id == buildingID }) {
				kingdoms[index].buildings[buildingIndex] = newBuilding
			}
		}
	}

	func getKingdomID(buildingID: UUID) async -> UUID? {
		for kingdom in kingdoms {
			for building in kingdom.buildings {
				if building.id == buildingID {
					return kingdom.id
				}
			}
		}
		return nil
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
