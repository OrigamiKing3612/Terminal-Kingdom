enum UseStationEvent {
	static func useStation(tile: StationTile) {
		switch tile.tileType {
			case .anvil:
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
			case .furnace(progress: _): // TODO: use the progress or remove it
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
			case .workbench:
				var options: [MessageOption] = []
				for Allrecipe in AllRecipes.allCases {
					let recipe = Allrecipe.recipe
					if recipe.station != .workbench {
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
					if canMake, Game.stages.builder.stage3Stages == .makeDoor {
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
}
