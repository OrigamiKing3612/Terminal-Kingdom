import Foundation

actor PlayerCharacter {
	private(set) var name: String = ""
	private(set) var items: [Item] = []
	#if DEBUG
		private(set) nonisolated(unsafe) var position: Player = .init(x: 5, y: 5)
	#else
		private(set) nonisolated(unsafe) var position: Player = .init(x: 55, y: 23)
	#endif
	private(set) var direction: PlayerDirection = .down
	private(set) var quests: [Quest] = []
	#if DEBUG
		private(set) var mapType: MapType = .mainMap {
			didSet {
				//! TODO: this might not work
				Task {
					await Game.shared.player.setMapType(mapType)
					switch mapType {
						case .mainMap:
							break
						case .mining:
							await MapBox.resetMiningMap()
						default:
							await MapBox.resetBuildingMap(mapType)
					}
					await MapBox.mapBox()
				}
			}
		}
	#else
		private(set) var mapType: MapType = .castle(side: .left)
	#endif
	//! TODO: remove nonisolated(unsafe)
	nonisolated(unsafe) var stats: Stats = .init()
	var canBuild: Bool = false

	func setName(_ name: String) {
		self.name = name
	}

	func has(item: ItemType) -> Bool {
		items.contains { $0.type == item }
	}

	func hasPickaxe() -> Bool {
		for item in items {
			if case .pickaxe = item.type {
				return true
			}
		}
		return false
	}

	func hasAxe() -> Bool {
		for item in items {
			if case .axe = item.type {
				return true
			}
		}
		return false
	}

	func has(item: ItemType, count: Int) -> Bool {
		items.filter { $0.type == item }.count >= count
	}

	func has(item: Item, count _: Int) -> Bool {
		items.contains(item)
	}

	func has(id: UUID) -> Bool {
		items.contains(where: { $0.id == id })
	}

	func getCount(of item: ItemType) -> Int {
		items.filter { $0.type == item }.count
	}

	enum RemoveDurabilityTypes {
		case pickaxe, axe
	}

	func removeDurability(of itemType: RemoveDurabilityTypes, count _: Int = 1, amount: Int = 1) {
		for (index, item) in items.enumerated() {
			switch (itemType, item.type) {
				case let (.pickaxe, .pickaxe(type)) where type.durability > amount:
					let newItem = Item(id: item.id, type: .pickaxe(type: .init(durability: type.durability - amount)), canBeSold: item.canBeSold)
					updateItem(at: index, newItem)
				case (.pickaxe, .pickaxe):
					removeItem(at: index)
				case let (.axe, .axe(type)) where type.durability > amount:
					let newItem = Item(id: item.id, type: .axe(type: .init(durability: type.durability - amount)), canBeSold: item.canBeSold)
					updateItem(at: index, newItem)
				case (.axe, .axe):
					removeItem(at: index)
				default:
					continue
			}
		}
	}

	func collect(item: Item) -> UUID {
		items.append(item)
		return item.id
	}

	func collect(item: Item, count: Int) -> [UUID] {
		var ids: [UUID] = []
		for _ in 0 ..< count {
			items.append(item)
			ids.append(item.id)
		}
		return ids
	}

	func destroyItem(id: UUID) {
		if items.isEmpty {
			return
		}
		let item = items.filter { $0.id == id }
		if !item.isEmpty, item[0].canBeSold {
			items.removeAll { $0.id == id }
		}
	}

	func removeItem(id: UUID) {
		if items.isEmpty {
			return
		}
		let item = items.filter { $0.id == id }
		if !item.isEmpty {
			items.removeAll { $0.id == id }
		}
	}

	func removeItems(ids: [UUID]) {
		if items.isEmpty {
			return
		}
		for id in ids {
			removeItem(id: id)
		}
	}

	func removeItem(at index: Int) {
		if items.isEmpty {
			return
		}
		items.remove(at: index)
	}

	func updateItem(at index: Int, _ newValue: Item) {
		if items.isEmpty {
			return
		}
		items[index] = newValue
	}

	func removeItem(item: ItemType, count: Int = 1) {
		if items.isEmpty {
			return
		}
		var removedCount = 0
		items.removeAll { currentItem in
			if currentItem.type == item, removedCount < count {
				removedCount += 1
				return true
			}
			return false
		}
	}

	func collectIfNotPresent(item: Item) -> UUID {
		if !has(item: item.type) {
			return collect(item: item)
		}
		return item.id
	}

	@available(*, deprecated, message: "Use `setPlayerPosition(x:y:)` instead")
	func updatePlayerPositionToSave(x: Int, y: Int) {
		position.x = x
		position.y = y
	}

	func setPlayerPosition(x: Int, y: Int) {
		position.x = x
		position.y = y
	}

	func addQuest(_ quest: Quest) {
		if !quests.contains(quest) {
			quests.append(quest)
		}
	}

	func removeQuest(quest: Quest) {
		quests.removeAll(where: { $0 == quest })
	}

	func removeQuest(index: Int) {
		quests.remove(at: index)
	}

	@discardableResult
	func removeLastQuest() -> Quest {
		quests.removeLast()
	}

	func updateLastQuest(newQuest: Quest) {
		quests.removeLast()
		quests.append(newQuest)
	}

	func setMapType(_ newMapType: MapType) {
		mapType = newMapType
	}

	func setDirection(_ newDirection: PlayerDirection) {
		direction = newDirection
	}
}

enum PlayerDirection: String, Codable {
	case up, down, left, right

	var render: String {
		get async {
			switch self {
				case .up: await Game.shared.config.useNerdFont ? "↑" : "^"
				case .down: await Game.shared.config.useNerdFont ? "↓" : "v"
				case .left: await Game.shared.config.useNerdFont ? "←" : "<"
				case .right: await Game.shared.config.useNerdFont ? "→" : ">"
			}
		}
	}
}

struct PlayerCharacterCodable: Codable {
	var name: String
	var items: [Item]
	var position: Player
	var direction: PlayerDirection
	var quests: [Quest]
	var stats: Stats
	var canBuild: Bool
}
