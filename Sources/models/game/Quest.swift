enum Quest: Codable, Equatable {
	case chopLumber(count: Int = 10, for: String? = nil)

	// MARK: Blacksmith

	case blacksmith1
	case blacksmith2
	case blacksmith3
	case blacksmith4
	case blacksmith5
	case blacksmith6
	case blacksmith7
	case blacksmith8
	case blacksmith9
	case blacksmith10

	// MARK: Mine

	case mine1
	case mine2
	case mine3
	case mine4
	case mine5
	case mine6
	case mine7
	case mine8
	case mine9
	case mine10

	// MARK: Builder

	case builder1
	case builder2
	case builder3
	case builder4
	case builder5
	case builder6
	case builder7
	case builder8
	case builder9
	case builder10

	var label: String {
		switch self {
			case let .chopLumber(count, `for`):
				if let `for` {
					"Go get \(count) lumber for the \(`for`)"
				} else {
					"Go get \(count) lumber"
				}
			case .blacksmith1: "Go get iron from the Mine and bring it to the blacksmith"
			case .blacksmith2: "Go get 20 lumber and band bring it to the blacksmith"
			case .blacksmith3: "Bring Lumber to the carpenter and bring it back to the blacksmith"
			case .blacksmith4: "Get 5 coal from the miner"
			case .blacksmith5: "Use the furnace to make steel"
			case .blacksmith6: "Make a pickaxe on the anvil"
			case .blacksmith7:
				switch Game.stages.blacksmith.stage7Stages {
					case .notStarted: "Blacksmith Stage 7 not started"
					case .makeSword: "Make a sword on the anvil"
					case .bringToHunter: "Bring the sword to the hunter"
					case .comeBack: "Return to the Blacksmith"
					case .done: "Blacksmith Stage 7 done"
				}
			case .blacksmith8:
				switch Game.stages.blacksmith.stage8Stages {
					case .notStarted: "Blacksmith Stage 8 not started"
					case .getMaterials: "Get materials from the Miner"
					case .makeSteel: "Make steel on the anvil"
					case .comeBack: "Return to the Blacksmith"
					case .done: "Blacksmith Stage 8 done"
				}
			case .blacksmith9: "Sell the steel in the shop"
			case .blacksmith10: "Collect gift from the blacksmith"
			case .mine1: "Get a pickaxe from the blacksmith and bring it to the Miner"
			case .mine2: "Mine 20 clay for the Miner"
			case .mine3: "Mine 50 lumber for the Miner to upgrade the mine"
			case .mine4:
				switch Game.stages.mine.stage4Stages {
					case .notStarted: "Mine Stage 4 not started"
					case .collectPickaxe: "Get a pickaxe from the blacksmith"
					case .mine: "Mine 30 stone for the Miner"
					case .done: "Mine Stage 4 done"
				}
			case .mine5: "Mine 20 iron for the Miner"
			case .mine6:
				switch Game.stages.mine.stage6Stages {
					case .notStarted: "Mine Stage 6 not started"
					case .goGetAxe: "Get an axe from the blacksmith"
					case .collect: "Collect 100 lumber to upgrade the mine"
					case .done: "Mine Stage 6 done"
				}
			case .mine7: "Upgrade the mine!"
			case .mine8: "Collect a gift from the Blacksmith"
			case .mine9: "Mine 5 gold for the miner"
			case .mine10:
				switch Game.stages.mine.stage10Stages {
					case .notStarted: "Mine Stage 10 not started"
					case .goToSalesman: "Bring the coins back to the miner"
					case .comeBack: "Return to the miner"
					case .done: "Mine Stage 10 done"
				}
			case .builder1: "Get materials from the Miner"
			case .builder2: "Collect 20 lumber for the builder"
			case .builder3: "Make a door on the workbench"
			case .builder4: "Go talk to the King"
			case .builder5: "Build a house for the builder"
			case .builder6: "Collect 30 lumber for the builder"
			case .builder7: "Decorate the inside of the house"
			case .builder8: "Talk to the builder"
			case .builder9: "Build a house for the builder"
			case .builder10: "Take the door and have fun!"
		}
	}
}
