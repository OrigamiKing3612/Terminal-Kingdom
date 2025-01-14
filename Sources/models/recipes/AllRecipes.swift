import Foundation

enum AllRecipes: CaseIterable {
	case pickaxe
	case steel
	case sword
	case door

	var recipe: Recipe {
		switch self {
			case .pickaxe:
				Recipe(ingredients: [.init(item: .stick, count: 2), .init(item: .steel, count: 3)], result: [.init(item: .pickaxe(type: .init(durability: 200)), count: 1)], station: .anvil)
			case .steel:
				Recipe(ingredients: [.init(item: .iron, count: 1), .init(item: .coal, count: 1)], result: [.init(item: .steel, count: 1)], station: .furnace)
			case .sword:
				Recipe(ingredients: [.init(item: .steel, count: 2), .init(item: .stick, count: 2)], result: [.init(item: .sword, count: 1)], station: .anvil)
			case .door:
				Recipe(ingredients: [.init(item: .lumber, count: 4), .init(item: .iron, count: 1)], result: [.init(item: .door(tile: .init(tileType: .house)), count: 1)], station: .workbench)
		}
	}
}
