enum UseFurnace {
	static func use(progress _: FurnaceProgress) {
		var options: [MessageOption] = []
		for Allrecipe in AllRecipes.allCases {
			let recipe = Allrecipe.recipe
			if recipe.station != .furnace {
				continue
			}
			var canMake = true
			for ingredient in recipe.ingredients {
				if Game.player.has(item: ingredient.item, count: ingredient.count) {
					continue
				} else {
					canMake = false
					break
				}
			}
			if canMake {
				options.append(.init(label: recipe.name, action: {
					for ingredient in recipe.ingredients {
						if Game.stages.blacksmith.stage5Stages == .makeSteel {
							if let ids = Game.stages.blacksmith.stage5ItemsToMakeSteelUUIDs {
								Game.player.removeItems(ids: ids)
							}
						} else if Game.stages.blacksmith.stage8Stages == .makeSteel {
							if let ids = Game.stages.blacksmith.stage8MaterialsToRemove {
								Game.player.removeItems(ids: ids)
							}
						} else {
							Game.player.removeItem(item: ingredient.item, count: ingredient.count)
						}
					}
					for result in recipe.result {
						if Game.stages.blacksmith.stage5Stages == .makeSteel {
							Game.stages.blacksmith.stage5Stages = .done
							Game.stages.blacksmith.stage5SteelUUIDsToRemove = Game.player.collect(item: .init(type: result.item, canBeSold: false), count: 5)
						} else if Game.stages.blacksmith.stage8Stages == .makeSteel {
							Game.stages.blacksmith.stage8Stages = .comeBack
							Game.stages.blacksmith.stage8MaterialsToRemove = Game.player.collect(item: .init(type: result.item, canBeSold: false), count: 3)
						} else {
							_ = Game.player.collect(item: .init(type: result.item, canBeSold: true))
						}
					}
				}))
			}
		}
		options.append(.init(label: "Quit", action: {}))
		let selectedOption = MessageBox.messageWithOptions("What would you like to make?", speaker: .game, options: options)
		selectedOption.action()
	}
}
