struct BlacksmithNPC {
    static func talk() {
        if Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith == false {
            Game.startingVillageChecks.firstTimes.hasTalkedToBlacksmith = true
        }
        if Game.stages.mine.stage1Stages == .collect {
            MessageBox.message("Ah, here you are. Here is your pickaxe.", speaker: .blacksmith)
            Game.stages.mine.stage1PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
            Game.stages.mine.stage1Stages = .bringBack
        } else if Game.stages.mine.stage4Stages == .collectPickaxe {
            MessageBox.message("Here you are. Here is your pickaxe.", speaker: .blacksmith)
            Game.stages.mine.stage4PickaxeUUIDToRemove = Game.player.collect(item: .init(type: .pickaxe(type: .init()), canBeSold: false))
            Game.stages.mine.stage4Stages = .mine
        } else if Game.stages.mine.stage6Stages == .goGetAxe {
            MessageBox.message("Here you are. Here is your axe.", speaker: .blacksmith)
            Game.stages.mine.stage6AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init(durability: 100)), canBeSold: false))
            Game.stages.mine.stage6Stages = .collect
        } else if Game.stages.mine.stage8Stages == .getPickaxe {
            MessageBox.message("Here you are. Here is your gift.", speaker: .blacksmith)
            Game.stages.mine.stage8PickaxeUUID = Game.player.collect(item: .init(type: .pickaxe(type: .init(durability: 1_000)), canBeSold: true))
        } else {
            getStage()
        }
    }

    static func getStage() {
        switch Game.stages.blacksmith.stageNumber {
            case 0:
                let options: [MessageOption] = [
                    .init(label: "Yes", action: {}),
                    .init(label: "No", action: {}),
                ]
                let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to be a blacksmith?", speaker: .blacksmith, options: options)
                if selectedOption.label == "Yes" {
                    Game.stages.blacksmith.next()
                    getStage()
                } else {
                    return
                }
            case 1:
                stage1()
            case 2:
                stage2()
            case 3:
                stage3()
            case 4:
                stage4()
            case 5:
                stage5()
            default:
                break
        }
    }

    static func stage1() {
        switch Game.stages.blacksmith.stage1Stages {
            case .notStarted, .goToMine:
                Game.stages.blacksmith.stage1Stages = .goToMine
                MessageBox.message("I need you to go get some iron from the mine. Then bring it back to me. The door to the mine will be a \"\("!".styled(with: [.red, .bold]))\" to help you find your way.", speaker: .blacksmith)
                StatusBox.quest(.blacksmith1)
            case .bringItBack:
                if Game.player.has(item: .iron, count: 5) {
                    MessageBox.message("Thank you!", speaker: .blacksmith)
                    if let ironUUID = Game.stages.blacksmith.stage1AIronUUIDsToRemove {
                        Game.player.removeItems(ids: ironUUID)
                    }
                    StatusBox.removeQuest(quest: .blacksmith1)
                    Game.stages.blacksmith.stage1Stages = .done
                    Game.player.stats.blacksmithSkillLevel = .one
                    fallthrough
                } else {
                    MessageBox.message("Somehow do don't have iron.", speaker: .blacksmith)
                }
            case .done:
                Game.stages.blacksmith.next()
                if RandomEventStuff.wantsToContinue(speaker: .blacksmith) {
                    getStage()
                }
        }
    }
    static func stage2() {
        switch Game.stages.blacksmith.stage2Stages {
            case .notStarted:
                Game.stages.blacksmith.stage2Stages = .getLumber
                MessageBox.message("Now I need you to get 20 lumber. Here is an axe.", speaker: .blacksmith)
                Game.stages.blacksmith.stage2AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init(durability: 100)), canBeSold: false))
                StatusBox.quest(.blacksmith2)
            case .getLumber:
                if Game.player.has(item: .lumber, count: 20) {
                    MessageBox.message("Thank you!", speaker: .blacksmith)
                    if let id  = Game.stages.blacksmith.stage2AxeUUIDToRemove {
                        Game.player.removeItem(id: id)
                    }
                    Game.player.removeItem(item: .lumber, count: 20)
                    StatusBox.removeQuest(quest: .blacksmith2)
                    Game.player.stats.blacksmithSkillLevel = .two
                    Game.stages.blacksmith.stage2Stages = .done
                    fallthrough
                } else {
                    if let stage2AxeUUIDToRemove = Game.stages.blacksmith.stage2AxeUUIDToRemove, !Game.player.has(id: stage2AxeUUIDToRemove) {
                        MessageBox.message("Uh oh, looks like you lost your axe, here is a new one.", speaker: .blacksmith)
                        Game.stages.blacksmith.stage2AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
                    }
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .clay) - 20)) clay.", speaker: .blacksmith)
                }
            case .done:
                Game.stages.blacksmith.next()
                if RandomEventStuff.wantsToContinue(speaker: .blacksmith) {
                    getStage()
                }
        }
    }
    static func stage3() {
        switch Game.stages.blacksmith.stage3Stages {
            case .notStarted:
                MessageBox.message("Now I need you to give this lumber to the carpenter to get sticks.", speaker: .blacksmith)
                Game.stages.blacksmith.stage3LumberUUIDsToRemove = Game.player.collect(item: .init(type: .lumber, canBeSold: false), count: 20)
                Game.stages.blacksmith.stage3Stages = .goToCarpenter
                StatusBox.quest(.blacksmith3)
            case .goToCarpenter:
                MessageBox.message("You haven't gone to the carpenter yet.", speaker: .blacksmith)
            case .comeBack:
                if Game.player.has(item: .stick, count: 20) {
                    MessageBox.message("Thank you!", speaker: .blacksmith)
                    StatusBox.removeQuest(quest: .blacksmith3)
                    if let sticksUUIDs = Game.stages.blacksmith.stage3LumberUUIDsToRemove {
                        Game.player.removeItems(ids: sticksUUIDs)
                    }
                    Game.player.stats.blacksmithSkillLevel = .three
                    Game.stages.blacksmith.stage3Stages = .done
                    fallthrough
                }
            case .done:
                Game.stages.blacksmith.next()
                if RandomEventStuff.wantsToContinue(speaker: .blacksmith) {
                    getStage()
                }
        }
    }
    static func stage4() {
        switch Game.stages.blacksmith.stage4Stages {
            case .notStarted:
                MessageBox.message("I need you to get 5 coal from the miner. We need the iron, lumber and this coal, because I want to show you how to make a pickaxe.", speaker: .blacksmith)
                Game.stages.blacksmith.stage4Stages = .collect
                StatusBox.quest(.blacksmith4)
            case .collect:
                MessageBox.message("You haven't gotten the coal yet.", speaker: .blacksmith)
            case .bringItBack:
                if Game.player.has(item: .coal, count: 5) {
                    MessageBox.message("Thank you!", speaker: .blacksmith)
                    StatusBox.removeQuest(quest: .blacksmith4)
                    if let coalUUIDs = Game.stages.blacksmith.stage4CoalUUIDsToRemove {
                        Game.player.removeItems(ids: coalUUIDs)
                    }
                    Game.player.stats.blacksmithSkillLevel = .four
                    Game.stages.blacksmith.stage4Stages = .done
                    fallthrough
                }
            case .done:
                Game.stages.blacksmith.next()
                if RandomEventStuff.wantsToContinue(speaker: .blacksmith) {
                    getStage()
                }
        }
    }
    static func stage5() {
        switch Game.stages.blacksmith.stage5Stages {
            case .notStarted:
                MessageBox.message("Now you get to do the fun stuff. I need to you make a picaxe. Go over to on of the furnace (\(StationTileType.furnace(progress: .empty).render))", speaker: .blacksmith)
                let uuids1 = Game.player.collect(item: .init(type: .coal, canBeSold: false), count: 5)
                let uuids2 = Game.player.collect(item: .init(type: .iron, canBeSold: false), count: 5)
                Game.stages.blacksmith.stage5ItemsToMakeSteelUUIDs = uuids1 + uuids2
                StatusBox.quest(.blacksmith5)
                Game.stages.blacksmith.stage5Stages = .makeSteel
            case .makeSteel:
                MessageBox.message("You haven't gone to the furnace yet. It is labled with an \"\(StationTileType.furnace(progress: .empty).render)\"", speaker: .blacksmith)
            case .returnToBlacksmith:
                if Game.player.hasPickaxe() {
                    MessageBox.message("Yay! You made your first Pickaxe!", speaker: .blacksmith)
                    StatusBox.removeQuest(quest: .blacksmith5)
                    Game.player.removeItems(ids: Game.stages.blacksmith.stage5SteelUUIDsToRemove)
                    Game.player.stats.blacksmithSkillLevel = .five
                    Game.stages.blacksmith.stage5Stages = .done
                    fallthrough
                }
            case .done:
                Game.stages.blacksmith.next()
                if RandomEventStuff.wantsToContinue(speaker: .blacksmith) {
                    getStage()
                }

        }
    }
}

enum BlacksmithStage1Stages: Codable {
    case notStarted, goToMine, bringItBack, done
}

enum BlacksmithStage2Stages: Codable {
    case notStarted, getLumber, done
}

enum BlacksmithStage3Stages: Codable {
    case notStarted, goToCarpenter, comeBack, done
}

enum BlacksmithStage4Stages: Codable {
    case notStarted, collect, bringItBack, done
}

enum BlacksmithStage5Stages: Codable {
    case notStarted, makeSteel, returnToBlacksmith, done
}

enum BlacksmithStage6Stages: Codable {
    case notStarted, makePickaxe, done
}

enum BlacksmithStage7Stages: Codable {
    case notStarted, makeSword, bringToHunter, done
}

enum BlacksmithStage8Stages: Codable {
    case notStarted, getMaterials, makeSteel, done
}

enum BlacksmithStage9Stages: Codable {
    case notStarted, goToSalesman, comeBack, done
}

