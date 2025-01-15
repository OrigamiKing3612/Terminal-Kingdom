enum UseAnvil {
	static func use() {
		var options: [MessageOption] = []
		for Allrecipe in AllRecipes.allCases {
			let recipe = Allrecipe.recipe
			if recipe.station != .anvil {
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
					// TODO: only allow the player to make what they need for a quest
					for ingredient in recipe.ingredients {
						if Game.stages.blacksmith.stage6Stages == .makePickaxe {
							if let ids = Game.stages.blacksmith.stage6ItemsToMakePickaxeUUIDs {
								Game.player.removeItems(ids: ids)
							}
						} else if Game.stages.blacksmith.stage7Stages == .makeSword {
							if let ids = Game.stages.blacksmith.stage7ItemsToMakeSwordUUIDs {
								Game.player.removeItems(ids: ids)
							}
						} else {
							Game.player.removeItem(item: ingredient.item, count: ingredient.count)
						}
						Game.player.removeItem(item: ingredient.item, count: ingredient.count)
					}
					for result in recipe.result {
						if Game.stages.blacksmith.stage6Stages == .makePickaxe {
							Game.stages.blacksmith.stage6Stages = .done
							Game.stages.blacksmith.stage6PickaxeUUIDToRemove = Game.player.collect(item: .init(type: result.item, canBeSold: false))
						} else if Game.stages.blacksmith.stage7Stages == .makeSword {
							Game.stages.blacksmith.stage7Stages = .bringToHunter
							Game.stages.blacksmith.stage7SwordUUIDToRemove = Game.player.collect(item: .init(type: result.item, canBeSold: false))
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
