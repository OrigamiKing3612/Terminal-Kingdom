enum BuilderNPC {
	static func talk() {
		if Game.startingVillageChecks.firstTimes.hasTalkedToBuilder == false {
			Game.startingVillageChecks.firstTimes.hasTalkedToBuilder = true
		}
		getStage()
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
			case 6:
				stage6()
			case 7:
				stage7()
			default:
				break
		}
	}

	static func stage0() {
		if Game.startingVillageChecks.hasBeenTaughtToChopLumber != .yes {
			if Game.startingVillageChecks.hasBeenTaughtToChopLumber == .no {
				MessageBox.message("Before I can teach you how to build, you need to learn how to chop lumber.", speaker: .builder)
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
			let selectedOption = MessageBox.messageWithOptions("Would you like to learn how to build?", speaker: .builder, options: options)
			if selectedOption.label == "Yes" {
				stage1()
			}
		}
	}

	static func stage1() {
		switch Game.stages.builder.stage1Stages {
			case .notStarted:
				MessageBox.message("Before we can start building, we need materials. Can you go collect 20 stone and 10 iron from the mine and bring it back to me?", speaker: .builder)
				Game.stages.builder.stage1Stages = .collect
				StatusBox.quest(.builder1)
			case .collect:
				MessageBox.message("You haven't gone to the mine yet. It will be marked with an \("!".styled(with: .bold)) on the map.", speaker: .builder)
			case .bringBack:
				if Game.player.has(item: .stone, count: 20), Game.player.has(item: .iron, count: 10) {
					MessageBox.message("Great, You have collected the materials!", speaker: .builder)
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
				MessageBox.message("Now, we need some lumber. Can you get 20 of it? Here is an axe.", speaker: .builder)
				Game.stages.builder.stage2Stages = .collect
				StatusBox.quest(.builder2)
				Game.stages.builder.stage2AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
			case .collect:
				if Game.player.has(item: .lumber, count: 20) {
					MessageBox.message("Great, You have collected the lumber! Now we can start building.", speaker: .builder)
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
						MessageBox.message("Uh oh, looks like you lost your axe. Here is a new one.", speaker: .builder)
						Game.stages.builder.stage2AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
					}
					MessageBox.message("You are almost there, but you still need to get \(abs(Game.player.getCount(of: .lumber) - 20)) lumber.", speaker: .builder)
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
				MessageBox.message("Now that we have the materials, we can start building. Can you make a door at the workstation. It is marked as a \(StationTileType.workbench.render). Here are the materials you will need.", speaker: .builder)
				Game.stages.builder.stage3Stages = .makeDoor
				StatusBox.quest(.builder3)
				let uuid1 = Game.player.collect(item: .init(type: .lumber, canBeSold: false), count: 4)
				let uuid2 = Game.player.collect(item: .init(type: .iron, canBeSold: false), count: 1)
				Game.stages.builder.stage3ItemsToMakeDoorUUIDsToRemove = uuid1 + uuid2
			case .makeDoor:
				MessageBox.message("You haven't made the door yet. It is marked with a \(StationTileType.workbench.render).", speaker: .builder)
			case .returnToBuilder:
				if Game.player.has(item: .door(tile: .init(type: .house)), count: 1) {
					MessageBox.message("Great, You have made the door!", speaker: .builder)
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
					MessageBox.message("You still need to make the door. It is marked with a \(StationTileType.workbench.render).", speaker: .builder)
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
				MessageBox.message("I see that you've talked to the king. What did he say?", speaker: .builder)
				MessageBox.message("He said we can build a new house!", speaker: .player)
				MessageBox.message("Nice! Lets get started right away!", speaker: .builder)
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
				MessageBox.message("Now that we have permission, we can start building immediately! Can you begin building the house?", speaker: .builder)
				instructions()
				Game.stages.builder.stage5Stages = .buildHouse
				Game.player.canBuild = true
				let uuid1 = Game.player.collect(item: .init(type: .lumber, canBeSold: false), count: 5 * 24)
				let uuid2 = Game.player.collect(item: .init(type: .door(tile: .init(type: .house)), canBeSold: false), count: 1)
				Game.stages.builder.stage5ItemsToBuildHouseUUIDsToRemove = uuid1 + uuid2
				StatusBox.quest(.builder5)
			case .buildHouse:
				if Game.stages.builder.stage5HasBuiltHouse {
					MessageBox.message("Nice, you have built the house!", speaker: .builder)
					Game.stages.builder.stage5Stages = .done
					Game.player.stats.builderSkillLevel = .five
					StatusBox.removeQuest(quest: .builder5)
					if let ids = Game.stages.builder.stage5ItemsToBuildHouseUUIDsToRemove {
						Game.player.removeItems(ids: ids)
					}
					Game.player.canBuild = false
					fallthrough
				} else {
					MessageBox.message("You haven't built the house yet.", speaker: .builder)
					MessageBox.messageWithOptions("Do you want to hear the instructions again?", speaker: .builder, options: [.init(label: "Yes", action: instructions), .init(label: "No", action: {})]).action()
				}
			case .done:
				Game.stages.builder.next()
				if RandomEventStuff.wantsToContinue(speaker: .builder) {
					getStage()
				}
		}
		func instructions() {
			MessageBox.message("This is what you need to do: Go pick an area and press \(KeyboardKeys.b.render). This will put you in \("build mode".styled(with: .bold)). Then press \(KeyboardKeys.enter.render), as long as you have 5 lumber you will build a building tile. Place the buildings next to each other. Then place the door in a small area. If you are unsure, look at the other buildings in this village. If you want to see all the controls press \(KeyboardKeys.questionMark.render) in build mode.", speaker: .builder)
		}
	}

	static func stage6() {
		switch Game.stages.builder.stage6Stages {
			case .notStarted:
				MessageBox.message("Now that we have a house, we need to decorate the interior. Can you collect 30 lumber and bring it back to me?", speaker: .builder)
				Game.stages.builder.stage6Stages = .collect
				StatusBox.quest(.builder6)
				Game.stages.builder.stage6AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
			case .collect:
				if Game.player.has(item: .lumber, count: 30) {
					MessageBox.message("Great! You have collected the lumber! Now we can start decorating the inside.", speaker: .builder)
					if let id = Game.stages.builder.stage6AxeUUIDToRemove {
						Game.player.removeItem(id: id)
					}
					Game.player.removeItem(item: .lumber, count: 30)
					Game.player.stats.builderSkillLevel = .six
					Game.stages.builder.stage6Stages = .done
					StatusBox.removeQuest(quest: .builder6)
					fallthrough
				} else {
					if let id = Game.stages.builder.stage6AxeUUIDToRemove, !Game.player.has(id: id) {
						MessageBox.message("Uh oh, looks like you lost your axe, here is a new one.", speaker: .builder)
						Game.stages.builder.stage6AxeUUIDToRemove = Game.player.collect(item: .init(type: .axe(type: .init()), canBeSold: false))
					}
					MessageBox.message("You are almost there, you you still need to get \(abs(Game.player.getCount(of: .lumber) - 30)) lumber.", speaker: .builder)
				}
			case .done:
				Game.stages.builder.next()
				if RandomEventStuff.wantsToContinue(speaker: .builder) {
					getStage()
				}
		}
	}

	static func stage7() {
		switch Game.stages.builder.stage7Stages {
			case .notStarted:
				MessageBox.message("Can you take these decorations and organize them inside of the house? You can decorate it however you want!", speaker: .builder)
				Game.stages.builder.stage7Stages = .buildInside
				StatusBox.quest(.builder7)
				let uuid1 = Game.player.collect(item: .init(type: .bed, canBeSold: false), count: 1)
				let uuid2 = Game.player.collect(item: .init(type: .chest, canBeSold: false), count: 2)
				let uuid3 = Game.player.collect(item: .init(type: .desk, canBeSold: false), count: 1)
				Game.stages.builder.stage7ItemsToBuildInsideUUIDsToRemove = uuid1 + uuid2 + uuid3
				Game.player.canBuild = true
			case .buildInside:
				if Game.stages.builder.stage7HasBuiltInside {
					MessageBox.message("Looks like you are done!", speaker: .builder)
					Game.stages.builder.stage7Stages = .done
					Game.player.stats.builderSkillLevel = .seven
					StatusBox.removeQuest(quest: .builder7)
					if let ids = Game.stages.builder.stage7ItemsToBuildInsideUUIDsToRemove {
						Game.player.removeItems(ids: ids)
					}
					Game.player.canBuild = false
					fallthrough
				} else {
					MessageBox.message("You haven't decorated the interior of your house yet.", speaker: .builder)
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
	case notStarted, buildHouse, done
}

enum BuilderStage6Stages: Codable {
	case notStarted, collect, done
}

enum BuilderStage7Stages: Codable {
	// TODO: add more cases
	case notStarted, buildInside, done
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
