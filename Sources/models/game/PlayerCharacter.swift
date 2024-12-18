import Foundation

struct PlayerCharacter: Codable {
    private(set) var name: String = ""
    private(set) var items: [Item] = []
    private(set) var position: Player = Player(x: 5, y: 5)
    private(set) var quests: [Quest] = []
    
    var stats: Stats = Stats()
    
    mutating func setName(_ name: String) {
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
    
    func has(item: Item, count: Int) -> Bool {
        items.contains(item)
    }
    
    func has(id: UUID) -> Bool {
        items.contains(where: { $0.id == id })
    }
    
    func getCount(of item: ItemType) -> Int {
        items.filter({$0.type == item}).count
    }
    
    enum RemoveDurabilityTypes {
        case pickaxe, axe
    }
    
    mutating func removeDurability(of itemType: RemoveDurabilityTypes, count: Int = 1, amount: Int = 1) {
        for (index, item) in items.enumerated() {
            switch (itemType, item.type) {
                case (.pickaxe, .pickaxe(let type)) where type.durability > amount:
                    let newItem = Item(id: item.id, type: .pickaxe(type: .init(durability: type.durability - amount)), canBeSold: item.canBeSold)
                    updateItem(at: index, newItem)
                case (.pickaxe, .pickaxe):
                    removeItem(at: index)
                case (.axe, .axe(let type)) where type.durability > amount:
                    let newItem = Item(id: item.id, type: .axe(type: .init(durability: type.durability - amount)), canBeSold: item.canBeSold)
                    updateItem(at: index, newItem)
                case (.axe, .axe):
                    removeItem(at: index)
                default:
                    continue
            }
        }
    }
    
    mutating func collect(item: Item) -> UUID {
        items.append(item)
        return item.id
    }
    
    mutating func collect(item: Item, count: Int) -> [UUID] {
        var ids: [UUID] = []
        for _ in 0..<count {
            items.append(item)
            ids.append(item.id)
        }
        return ids
    }
    
    mutating func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }
    
    mutating func removeItems(ids: [UUID]) {
        for id in ids {
            removeItem(id: id)
        }
    }
    
    mutating func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    mutating func updateItem(at index: Int, _ newValue: Item) {
        items[index] = newValue
    }
    
    mutating func removeItem(item: ItemType, count: Int = 1) {
        var removedCount = 0
        items.removeAll { currentItem in
            if currentItem.type == item && removedCount < count {
                removedCount += 1
                return true
            }
            return false
        }
    }
    mutating func collectIfNotPresent(item: Item) -> UUID {
        if !self.has(item: item.type) {
            return self.collect(item: item)
        }
        return item.id
    }
    
    mutating func updatePlayerPositionToSave(x: Int, y: Int) {
        self.position.x = x
        self.position.y = y
    }
    
    mutating func addQuest(_ quest: Quest) {
        if !quests.contains(quest) {
            quests.append(quest)
        }
    }
    
    mutating func removeQuest(quest: Quest) {
        quests.removeAll(where: { $0 == quest })
    }
    
    mutating func removeQuest(index: Int) {
        quests.remove(at: index)
    }
    
    @discardableResult
    mutating func removeLastQuest() -> Quest {
        quests.removeLast()
    }
    
    mutating func updateLastQuest(newQuest: Quest) {
        quests.removeLast()
        quests.append(newQuest)
    }
}
