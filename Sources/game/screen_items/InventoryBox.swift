import Foundation

struct InventoryBox {
    nonisolated(unsafe) static var showInventoryBox = true {
        didSet {
            if showInventoryBox {
                inventoryBox()
            } else {
                clear()
            }
        }
    }
    
    static func inventoryBox() {
        clear()
        
        Screen.print(x: q3StartX, y: q3StartY - 1, String(repeating: "=", count: q3Width + 3))
        for y in (q3StartY)..<q3EndY {
            Screen.print(x: q3StartX, y: y, "|")
            Screen.print(x: q3EndX, y: y, "|")
        }
        Screen.print(x: q3StartX, y: q3EndY, String(repeating: "=", count: q3Width + 3))
        printInventory()
    }
    
    static func printInventory() {
        clear()
        var alreadyPrinted: [Item] = []
        for item in Game.player.items {
            if !alreadyPrinted.contains(where: {$0 == item}) {
                Screen.print(x: q3StartX + 2, y: q3StartY + alreadyPrinted.count, "\(item.inventoryName): \(Game.player.getCount(of: item))")
                alreadyPrinted.append(item)
            }
        }
    }
    
    static func clear() {
        let spaceString = String(repeating: " ", count: q3Width + 1)
        for y in (q3StartY)..<q3EndY {
            Screen.print(x: q3StartX + 2, y: y, spaceString)
        }
    }
}
