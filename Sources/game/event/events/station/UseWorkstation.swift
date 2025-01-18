enum UseWorkstation {
	static func use() {
		var options: [MessageOption] = []
		for Allrecipe in AllRecipes.allCases {
			let recipe = Allrecipe.recipe
			if recipe.station != .workbench {
				continue
			}
			if recipe.result[0].item == .door(tile: .init(type: .house)) {
				if !(Game.stages.builder.stage3Stages == .makeDoor) {
					continue
				}
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
						if Game.stages.builder.stage3Stages == .makeDoor {
							if let ids = Game.stages.builder.stage3ItemsToMakeDoorUUIDsToRemove {
								Game.player.removeItems(ids: ids)
							}
						} else {
							Game.player.removeItem(item: ingredient.item, count: ingredient.count)
						}
					}
					for result in recipe.result {
						if Game.stages.builder.stage3Stages == .makeDoor {
							Game.stages.builder.stage3Stages = .returnToBuilder
							Game.stages.builder.stage3DoorUUIDToRemove = Game.player.collect(item: .init(type: result.item, canBeSold: false))
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
