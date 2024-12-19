struct CarpenterNPC {
    static func talk() {
        if Game.startingVillageChecks.firstTimes.hasTalkedToCarpenter == false {
            Game.startingVillageChecks.firstTimes.hasTalkedToCarpenter = true
        }
        if Game.stages.blacksmith.stage3Stages == .goToCarpenter {
            MessageBox.message("Here are your sticks.", speaker: .carpenter)
            if let lumberUUIDs = Game.stages.blacksmith.stage3LumberUUIDsToRemove {
                Game.player.removeItems(ids: lumberUUIDs)
            }
            Game.stages.blacksmith.stage3LumberUUIDsToRemove = Game.player.collect(item: .init(type: .stick, canBeSold: false), count: 20)
            Game.stages.blacksmith.stage3Stages = .comeBack
        } else {
            if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
                let options: [MessageOption] = [
                    .init(label: "Yes", action: {}),
                    .init(label: "No", action: {})
                ]
                let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn carpentry?", speaker: .carpenter, options: options)
                if selectedOption.label == "Yes" {
                    stage0()
                } else {
                    return
                }
            } else {
                stage0()
            }
        }
    }

    static func stage0() {
        if Game.startingVillageChecks.hasBeenTaughtToChopLumber != .yes {
            if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
                MessageBox.message("Before I can teach you carpentry, you need to learn how to chop lumber.", speaker: .carpenter)
            }
            RandomEventStuff.teachToChopLumber(by: .carpenter)
            if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .yes {
                stage1()
            }
        } else {
            MessageBox.message("Looks like you already know how to chop lumber. Lets start.", speaker: .carpenter)
            stage1()
        }
    }
    static func stage1() {
        MessageBox.message("I need you to....", speaker: .carpenter)
    }
}
