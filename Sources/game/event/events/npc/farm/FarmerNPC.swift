enum FarmerNPC {
	static func talk() async {
		if await Game.shared.startingVillageChecks.firstTimes.hasTalkedToFarmer == false {
			await Game.shared.startingVillageChecks.setHasTalkedToFarmer()
		}
		await getStage()
	}

	static func getStage() async {
		switch await Game.shared.stages.farm.stageNumber {
			case 0:
				let options: [MessageOption] = [
					.init(label: "Yes", action: {}),
					.init(label: "No", action: {}),
				]
				let selectedOption = await MessageBox.messageWithOptions("Hello \(Game.shared.player.name)! Would you like to learn how to be a farmer?", speaker: .farmer, options: options)
				if selectedOption.label == "Yes" {
					await Game.shared.stages.farm.next()
					await getStage()
				} else {
					return
				}
			case 1:
				await stage1()
			case 2:
				await stage2()
			default:
				break
		}
	}

	static func stage1() async {
		switch await Game.shared.stages.farm.stage1Stages {
			case .notStarted:
				await MessageBox.message("We need some seeds to plant. Can you go chop down a tree and get a tree seed?", speaker: .farmer)
				await Game.shared.stages.farm.setStage1AxeUUIDsToRemove(Game.shared.player.collect(item: .init(type: .axe(type: .init(durability: 1)), canBeSold: false)))
				await Game.shared.stages.farm.setStage1Stages(.collect)
				await StatusBox.quest(.farm1)
			case .collect:
				if await Game.shared.player.has(item: .tree_seed) {
					await MessageBox.message("Great job!", speaker: .farmer)
					await Game.shared.player.removeItem(item: .tree_seed)
					await Game.shared.stages.farm.setStage1Stages(.done)
					await StatusBox.removeQuest(quest: .farm1)
					await Game.shared.player.setFarmingSkillLevel(.one)
				} else {
					if let id = await Game.shared.stages.farm.stage1AxeUUIDToRemove, await !Game.shared.player.has(id: id) {
						await MessageBox.message("Uh oh, looks like you lost your axe. Here is a new one.", speaker: .builder)
						await Game.shared.stages.farm.setStage1AxeUUIDsToRemove(Game.shared.player.collect(item: .init(type: .axe(type: .init(durability: 1)), canBeSold: false)))
					}
					await MessageBox.message("You are almost there, but you still need to get \(abs(Game.shared.player.getCount(of: .lumber) - 20)) lumber.", speaker: .builder)
				}
			case .done:
				await Game.shared.stages.farm.next()
				if await RandomEventStuff.wantsToContinue(speaker: .farmer) {
					await getStage()
				}
		}
	}

	static func stage2() async {
		switch await Game.shared.stages.farm.stage2Stages {
			case .notStarted:
				await MessageBox.message("Now that we have seeds, we need to plant them. There is a pot in the room under me, go plant it in there.", speaker: .farmer)
				await Game.shared.stages.farm.setStage2Stages(.plant)
				await Game.shared.stages.farm.setStage2SeedUUIDsToRemove(Game.shared.player.collect(item: .init(type: .tree_seed, canBeSold: false)))
				await StatusBox.quest(.farm2)
			case .plant:
				await MessageBox.message("You haven't planted the seed yet.", speaker: .farmer)
			case .comeback:
				await MessageBox.message("Great job! Now it can start growing!", speaker: .farmer)
				await Game.shared.stages.farm.setStage2Stages(.done)
				await StatusBox.removeQuest(quest: .farm2)
				await Game.shared.player.setFarmingSkillLevel(.two)
			case .done:
				await Game.shared.stages.farm.next()
				if await RandomEventStuff.wantsToContinue(speaker: .farmer) {
					await getStage()
				}
		}
	}
}

enum FarmStage1Stages: Codable {
	case notStarted, collect, done
}

enum FarmStage2Stages: Codable {
	case notStarted, plant, comeback, done
}
