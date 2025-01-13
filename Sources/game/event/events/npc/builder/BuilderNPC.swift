enum BuilderNPC {
	static func talk() {
		if Game.startingVillageChecks.firstTimes.hasTalkedToBuilder == false {
			Game.startingVillageChecks.firstTimes.hasTalkedToBuilder = true
		}
		getStage()
	}

	static func getStage() {
		stage3()
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
		// case 2:
		// stage2()
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
					Game.stages.builder.stage2Stages = .done
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
				if Game.player.has(item: .door(tile: .init(type: .house)), count: 1) {
					MessageBox.message("Great! You have made the door.", speaker: .builder)
					if let ids = Game.stages.builder.stage3ItemsToMakeDoorUUIDsToRemove {
						Game.player.removeItems(ids: ids)
					}
					if let id = Game.stages.builder.stage3DoorUUIDToRemove {
						Game.player.removeItem(id: id)
					}
					Game.stages.builder.stage3Stages = .done
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
