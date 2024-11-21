struct MineDoorEvent {
    static func open(tile: DoorTile) {
        var options: [MessageOption] = [
            .init(label: "Go Inside", action: { goInside(tile: tile) }),
        ]
        if Game.stages.mine.stageNumber >= 1 && Game.player.hasPickaxe() {
            options.append(.init(label: "Start Mining", action: { MapBox.mapType = .mine }))
        }
        if tile.isPartOfPlayerVillage {
            options.append(.init(label: "Upgrade", action: { upgrade(tile: tile) }))
        }
        options.append(.init(label: "Quit", action: {}))
        let selectedOption = MessageBox.messageWithOptions("What would you like to do?", speaker: .game, options: options)
        selectedOption.action()
    }
    static func goInside(tile: DoorTile) {
        //TODO: Map changed to be a "map" of the building
        MessageBox.message("You go inside the door. You walk up to the miner. You say hello.", speaker: .game)

        if Game.stages.blacksmith.stage1Stages == .goToMine {
            MessageBox.message("Ah, here you are. This is the iron the \("Blacksmith".styled(with: .bold)) needs.", speaker: .miner)
            Game.stages.blacksmith.stage1Stages = .bringItBack
            Game.player.collect(item: .iron)
        } else {
            switch Game.stages.mine.stageNumber {
                case 0:
                    if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
                        let options: [MessageOption] = [
                            .init(label: "Yes", action: { goInside(tile: tile) }),
                            .init(label: "No", action: { })
                        ]
                        let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to mine?", speaker: .miner, options: options)
                        if selectedOption.label == "Yes" {
                            stage0()
                        } else {
                            return
                        }
                    } else {
                        stage0()
                    }
                case 1:
                    stage1()
                default:
                    break
            }
        }
    }
    static func stage0() {
        if Game.startingVillageChecks.hasBeenTaughtToChopLumber != .yes {
            if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
                MessageBox.message("Before I can teach you how to mine, you need to learn how to chop lumber.", speaker: .miner)
            }
            OpenDoorEvent.teachToChopLumber(by: .miner)
            if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .yes {
                stage1()
            }
        } else {
            MessageBox.message("Looks like you already know how to chop lumber. Lets start.", speaker: .miner)
            stage1()
        }
    }
    static func stage1() {
        Game.stages.mine.stageNumber = 1
        switch Game.stages.mine.stage1Stages {
            case .notStarted:
                MessageBox.message("I need you to mine 20 stone. You can do this by mining. Here is a pickaxe. Be careful, it can only be used 50 times. ", speaker: .miner)
                StatusBox.quest(.mine1)
                MessageBox.message("Oh also, press '\("l".styled(with: .bold))' to leave the mine.", speaker: .miner)
                MapBox.mapType = .mine
                Game.player.collect(item: .pickaxe())
                Game.stages.mine.stage1Stages = .mine
            case .mine:
                if Game.player.has(item: .stone, count: 20) {
                    MessageBox.message("Yay thank you! You have collected enough stone.", speaker: .miner)
                    Game.player.stats.miningSkillLevel = .one 
                    Game.player.remove(item: .stone, count: 20)
                    StatusBox.removeQuest(quest: .mine1)
                    Game.stages.mine.stage1Stages = .done
                } else {
                    if !Game.player.hasPickaxe() {
                        MessageBox.message("Uh oh, looks like you lost your pickaxe, here is a new one.", speaker: .miner)
                        Game.player.collect(item: .pickaxe())
                    }
                    MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .stone) - 20)) stone.", speaker: .miner)
                }
            case .done:
                //TODO: do I need anything here?
                break
            
        }
    }
    static func upgrade(tile: DoorTile) {
        //TODO: upgrade building
    }
}

enum MineStage1Stages: Codable {
    case notStarted, mine, done
}

