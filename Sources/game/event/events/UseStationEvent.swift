struct UseStationEvent {
    static func useStation(tile: StationTile) {
        switch tile.type {
            case .anvil:
                break
            case .furnace(progress: _): //TODO: use the progress or remove it
                var options: [MessageOption] = []
                for Allrecipe in AllRecipes.allCases {
                    let recipe = Allrecipe.recipe
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
                                } else {
                                    Game.player.removeItem(item: ingredient.item, count: ingredient.count)
                                }
                                Game.player.removeItem(item: ingredient.item, count: ingredient.count)
                            }
                            for result in recipe.result {
                                if Game.stages.blacksmith.stage5Stages == .makeSteel {
                                    Game.stages.blacksmith.stage5Stages = .done
                                    Game.stages.blacksmith.stage5SteelUUIDsToRemove = Game.player.collect(item: .init(type: result.item, canBeSold: false), count: 5)
                                } else {
                                    _ = Game.player.collect(item: .init(type: result.item, canBeSold: true))
                                }
                            }
                        }))
                    }
                }
                let selectedOption = MessageBox.messageWithOptions("What would you like to make?", speaker: .game, options: options)
                selectedOption.action()
        }
    }
}
