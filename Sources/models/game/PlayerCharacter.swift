struct PlayerCharacter: Codable {
    private(set) var name: String = ""
    private(set) var items: [Item] = []
    private(set) var position: Player = Player(x: 5, y: 5)
    private(set) var quests: [Quest] = []

    var stats: Stats = Stats()
    
    mutating func setName(_ name: String) {
        self.name = name
    }
    
    func has(item: Item) -> Bool {
        items.contains(item)
    }
    
    func hasPickaxe(withDurability: Int = 0) -> Bool {
        for item in items {
            if case .pickaxe(let durability) = item {
                if durability > withDurability {
                    return true
                }
            }
        }
        return false
    }
    
    func has(item: Item, count: Int) -> Bool {
        items.filter { $0 == item }.count >= count
    }
    
    func getCount(of item: Item) -> Int {
        items.filter({$0 == item}).count
    }
    
    mutating func removeDurability(of item: Item, count: Int = 1) {
        for (index, item) in items.enumerated() {
            if case .pickaxe(let durability) = item {
                if durability > 1 {
                    updateItem(at: index, .pickaxe(durability: durability - count)) // Decrease durability
                } else {
                    removeItem(at: index) // Remove if durability reaches 0
                }
            }
        }
    }
    
    mutating func collect(item: Item, count: Int = 1) {
        if count == 1 {
            items.append(item)
        } else {
            for _ in 0..<count {
                items.append(item)
            }
        }
    }
    
    mutating func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    mutating func updateItem(at index: Int, _ newValue: Item) {
        items[index] = newValue
    }
    
    mutating func remove(item: Item, count: Int = 1) {
        if has(item: item, count: count) {
            var removedCount = 0
            items.removeAll { currentItem in
                if currentItem == item && removedCount < count {
                    removedCount += 1
                    return true
                }
                return false
            }
        }
    }
    mutating func collectIfNotPresent(item: Item) {
        if !self.has(item: item) {
            self.collect(item: item)
        }
    }
    mutating func updatePlayerPositionToSave(x: Int, y: Int) {
        self.position.x = x
        self.position.y = y
    }
    mutating func quest(_ quest: Quest) {
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
