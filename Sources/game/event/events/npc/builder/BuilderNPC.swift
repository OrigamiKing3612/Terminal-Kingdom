enum BuilderNPC {
	static func talk() {
		if Game.startingVillageChecks.firstTimes.hasTalkedToBuilder == false {
			Game.startingVillageChecks.firstTimes.hasTalkedToBuilder = true
		}
		if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
			let options: [MessageOption] = [
				.init(label: "Yes", action: {}),
				.init(label: "No", action: {}),
			]
			let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to build?", speaker: .builder, options: options)
			if selectedOption.label == "Yes" {
				stage0()
			} else {
				return
			}
		} else {
			stage0()
		}
	}

	static func getStage() {
		switch Game.stages.builder.stageNumber {
			case 0:
				if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
					let options: [MessageOption] = [
						.init(label: "Yes", action: {}),
						.init(label: "No", action: {}),
					]
					let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to build?", speaker: .builder, options: options)
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
				MessageBox.message("Before I can teach you how to build, you need to learn how to chop lumber.", speaker: .builder)
			}
			RandomEventStuff.teachToChopLumber(by: .builder)
			if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .yes {
				stage1()
			}
		} else {
			MessageBox.message("Looks like you already know how to chop lumber. Lets start.", speaker: .builder)
			stage1()
		}
	}

	static func stage1() {
		MessageBox.message("I need you to....", speaker: .builder)
	}
}

enum BuilderStage1Stages: Codable {
	case notStarted, collect, bringBack, done
}

enum BuilderStage2Stages: Codable {
	case notStarted, collect, comeBack, done
}

enum BuilderStage3Stages: Codable {
	case notStarted, makeDoor, returnToBuilder, done
}

enum BuilderStage4Stages: Codable {
	case notStarted, talkToKing, comeBack, done
}

enum BuilderStage5Stages: Codable {
	// TODO: add more cases
	case notStarted, done
}

enum BuilderStage6Stages: Codable {
	case notStarted, collect, bringBack, done
}

enum BuilderStage7Stages: Codable {
	// TODO: add more cases
	case notStarted, done
}

enum BuilderStage8Stages: Codable {
	// TODO: add more cases
	case notStarted, done
}

enum BuilderStage9Stages: Codable {
	// TODO: add more cases
	case notStarted, done
}

enum BuilderStage10Stages: Codable {
	// TODO: add more cases
	case notStarted, done
}
