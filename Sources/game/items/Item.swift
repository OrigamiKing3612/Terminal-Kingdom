import Foundation

struct Item: Codable, Equatable, Hashable {
    let id: UUID
    let type: ItemType
    let canBeSold: Bool

    var price: Int? {
        type.price
    }
    var inventoryName: String {
        type.inventoryName
    }

    init(id: UUID = UUID(), type: ItemType, canBeSold: Bool = true) {
        self.id = id
        self.type = type
        if type == .coin {
            self.canBeSold = false
        } else {
            self.canBeSold = canBeSold
        }
    }
}
