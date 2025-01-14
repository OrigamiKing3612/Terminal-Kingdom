enum BuilderNPC {
	static func talk() {
		if Game.startingVillageChecks.firstTimes.hasTalkedToBuilder == false {
			Game.startingVillageChecks.firstTimes.hasTalkedToBuilder = true
		}
		getStage()
	}

	static func getStage() {
		stage5()
		// switch Game.stages.builder.stageNumber {
		// 	case 0:
		// 		if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
		// 			let options: [MessageOption] = [
		// 				.init(label: "Yes", action: {}),
		// 				.init(label: "No", action: {}),
		// 			]
		// 			let selectedOption = MessageBox.messageWithOptions("Hello \(Game.player.name)! Would you like to learn how to build?", speaker: .builder, options: options)
		// 			if selectedOption.label == "Yes" {
		// 				stage0()
		// 			} else {
		// 				return
		// 			}
		// 		} else {
		// 			stage0()
		// 		}
		// 	case 1:
		// 		stage1()
		// 	case 2:
		// 		stage2()
		// 	case 3:
		// 		stage3()
		// 	case 4:
		// 		stage4()
		// 	default:
		// 		break
		// }
	}

	static func stage0() {
		if Game.startingVillageChecks.hasBeenTaughtToChopLumber != .yes {
			if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
				MessageBox.message("Before I can teach you how to mine, you need to learn how to chop lumber.", speaker: .builder)
			}
			RandomEventStuff.teachToChopLumber(by: .builder)
			if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .yes {
				if RandomEventStuff.wantsToContinue(speaker: .builder) {
					stage1()
				}
			}
		} else {
			MessageBox.message("Hello \(Game.player.name)! Looks like you already know how to chop lumber.", speaker: .builder)
			let options: [MessageOption] = [
				.init(label: "Yes", action: {}),
				.init(label: "No", action: {}),
			]
			let selectedOption = MessageBox.messageWithOptions("Would you like to learn how to mine?", speaker: .builder, options: options)
			if selectedOption.label == "Yes" {
				stage1()
			}
		}
	}

	static func stage1() {
		switch Game.stages.builder.stage1Stages {
			case .notStarted:
				MessageBox.message("Before we can start building we need materials. Can you go get 20 stone and 10 iron from the mine and bring it back to me?", speaker: .builder)
				Game.stages.builder.stage1Stages = .collect
				StatusBox.quest(.builder1)
			case .collect:
				MessageBox.message("You haven't gone to the mine yet. It will be marked with an \("!".styled(with: .bold)) on the map.", speaker: .builder)
			case .bringBack:
				if Game.player.has(item: .stone, count: 20), Game.player.has(item: .iron, count: 10) {
					MessageBox.message("Great! You have collected the materials.", speaker: .builder)
					if let ids = Game.stages.builder.stage1ItemsUUIDsToRemove {
						Game.player.removeItems(ids: ids)
					}
					Game.stages.builder.stage1Stages = .done
					Game.player.stats.builderSkillLevel = .one
					StatusBox.removeQuest(quest: .builder1)
					fallthrough
				} else {
					MessageBox.message("You still need to collect the materials. It will be marked with an \("!".styled(with: .bold)) on the map.", speaker: .builder)
				}
			case .done:
				Game.stages.builder.next()
				if RandomEventStuff.wantsToContinue(speaker: .builder) {
					getStage()
				}
		}
	}

	static func stage2() {
		switch Game.stages.builder.stage2Stages {
			case .notStarted:
				MessageBox.message("Now we need some lumber, can you go get 20 of it? Here is an axe.", speaker: .builder)
				Game.stages.builder.stage2Stages = .collect
				StatusBox.quest(.builder2)
				Game.stages.builder.stage2AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
			case .collect:
				if Game.player.has(item: .lumber, count: 20) {
					MessageBox.message("Great! You have collected the lumber. Now we can start building.", speaker: .builder)
					if let id = Game.stages.builder.stage2AxeUUIDToRemove {
						Game.player.removeItem(id: id)
					}
					Game.player.removeItem(item: .lumber, count: 20)
					Game.player.stats.builderSkillLevel = .two
					Game.stages.builder.stage2Stages = .done
					StatusBox.removeQuest(quest: .builder2)
					fallthrough
				} else {
					if let id = Game.stages.builder.stage2AxeUUIDToRemove, !Game.player.has(id: id) {
						MessageBox.message("Uh oh, looks like you lost your axe, here is a new one.", speaker: .builder)
						Game.stages.builder.stage2AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
					}
					MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .lumber) - 20)) lumber.", speaker: .builder)
				}
			case .done:
				Game.stages.builder.next()
				if RandomEventStuff.wantsToContinue(speaker: .builder) {
					getStage()
				}
		}
	}

	static func stage3() {
		switch Game.stages.builder.stage3Stages {
			case .notStarted:
				MessageBox.message("Now that we have the materials, we can start building. Can you go make a door on the workstation. It is marked as a \(StationTileType.workbench.render). Here are the materials you will need.", speaker: .builder)
				Game.stages.builder.stage3Stages = .makeDoor
				StatusBox.quest(.builder3)
				let uuid1 = Game.player.collect(item: .init(type: .lumber, canBeSold: false), count: 4)
				let uuid2 = Game.player.collect(item: .init(type: .iron, canBeSold: false), count: 1)
				Game.stages.builder.stage3ItemsToMakeDoorUUIDsToRemove = uuid1 + uuid2
			case .makeDoor:
				MessageBox.message("You haven't made the door yet. It is marked as a \(StationTileType.workbench.render).", speaker: .builder)
			case .returnToBuilder:
				if Game.player.has(item: .door(tile: .init(tileType: .house)), count: 1) {
					MessageBox.message("Great! You have made the door.", speaker: .builder)
					if let ids = Game.stages.builder.stage3ItemsToMakeDoorUUIDsToRemove {
						Game.player.removeItems(ids: ids)
					}
					if let id = Game.stages.builder.stage3DoorUUIDToRemove {
						Game.player.removeItem(id: id)
					}
					Game.stages.builder.stage3Stages = .done
					Game.player.stats.builderSkillLevel = .three
					StatusBox.removeQuest(quest: .builder3)
					fallthrough
				} else {
					MessageBox.message("You still need to make the door. It is marked as a \(StationTileType.workbench.render).", speaker: .builder)
				}
			case .done:
				Game.stages.builder.next()
				if RandomEventStuff.wantsToContinue(speaker: .builder) {
					getStage()
				}
		}
	}

	static func stage4() {
		switch Game.stages.builder.stage4Stages {
			case .notStarted:
				MessageBox.message("Now that we have the door, we can start building. Can you go talk to the king and ask him for permission to build a house?", speaker: .builder)
				Game.stages.builder.stage4Stages = .talkToKing
				StatusBox.quest(.builder4)
			case .talkToKing:
				MessageBox.message("You haven't talked to the king yet.", speaker: .builder)
			case .comeBack:
				MessageBox.message("I see you've talked to the king. What did he say?", speaker: .builder)
				MessageBox.message("He said we can build a new house!", speaker: .player)
				MessageBox.message("Nice! Lets get started", speaker: .builder)
				Game.stages.builder.stage4Stages = .done
				Game.player.stats.builderSkillLevel = .four
				StatusBox.removeQuest(quest: .builder4)
				fallthrough
			case .done:
				Game.stages.builder.next()
				if RandomEventStuff.wantsToContinue(speaker: .builder) {
					getStage()
				}
		}
	}

	static func stage5() {
		switch Game.stages.builder.stage5Stages {
			case .notStarted:
				MessageBox.message("Now that we have permission to build a house, we can start building. Can you go build the house?", speaker: .builder)
				intructions()
				Game.stages.builder.stage5Stages = .buildHouse
				Game.player.canBuild = true
				let uuid1 = Game.player.collect(item: .init(type: .lumber, canBeSold: false), count: 5 * 24)
				let uuid2 = Game.player.collect(item: .init(type: .door(tile: .init(tileType: .house)), canBeSold: false), count: 1)
				Game.stages.builder.stage5ItemsToBuildHouseUUIDsToRemove = uuid1 + uuid2
				StatusBox.quest(.builder5)
			case .buildHouse:
				if Game.stages.builder.stage5HasBuiltHouse {
					MessageBox.message("Nice you have built the house!", speaker: .builder)
					Game.stages.builder.stage5Stages = .done
					Game.player.stats.builderSkillLevel = .five
					StatusBox.removeQuest(quest: .builder5)
					if let ids = Game.stages.builder.stage5ItemsToBuildHouseUUIDsToRemove {
						Game.player.removeItems(ids: ids)
					}
					fallthrough
				} else {
					MessageBox.message("You haven't built the house yet.", speaker: .builder)
					MessageBox.messageWithOptions("Do you want to hear the intructions again?", speaker: .builder, options: [.init(label: "Yes", action: intructions), .init(label: "No", action: {})]).action()
				}
			case .done:
				Game.stages.builder.next()
				if RandomEventStuff.wantsToContinue(speaker: .builder) {
					getStage()
				}
		}
		func intructions() {
			MessageBox.message("This is what you need to do. Go pick an area and press \(KeyboardKeys.b.render). This will put you in \("build mode".styled(with: .bold)). The press \(KeyboardKeys.enter.render), as long as you have 5 lumber you will build a building tile. Place the buildings next to each other. Then place the door in a small area. If you are unsure, look at the other buildings in this village. If you want to see all the controls press \(KeyboardKeys.questionMark.render) in build mode.", speaker: .builder)
		}
	}
}

enum BuilderStage1Stages: Codable {
	case notStarted, collect, bringBack, done
}

enum BuilderStage2Stages: Codable {
	case notStarted, collect, done
}

enum BuilderStage3Stages: Codable {
	case notStarted, makeDoor, returnToBuilder, done
}

enum BuilderStage4Stages: Codable {
	case notStarted, talkToKing, comeBack, done
}

enum BuilderStage5Stages: Codable {
	case notStarted, buildHouse, done
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
