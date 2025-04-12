enum HouseUpgrades {
	static let upgrades: [Int: BuildingUpgrade] = [
		2: .init(cost: [.init(item: .lumber, count: 50)]),
		3: .init(cost: [.init(item: .lumber, count: 100)]),
		4: .init(cost: [.init(item: .lumber, count: 150)]),
	]
}
