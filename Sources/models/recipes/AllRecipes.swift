import Foundation

enum AllRecipes: CaseIterable {
    case pickaxe
    case steel

    var recipe: Recipe {
        switch self {
            case .pickaxe:
                return Recipe(ingredients: [.init(item: .stick, count: 2), .init(item: .steel, count: 3)], result: [.init(item: .pickaxe(type: .init(durability: 200)), count: 1)], station: .anvil)
            case .steel:
                return Recipe(ingredients: [.init(item: .iron, count: 1), .init(item: .coal, count: 1)], result: [.init(item: .steel, count: 1)], station: .furnace)
        }
    }
}
