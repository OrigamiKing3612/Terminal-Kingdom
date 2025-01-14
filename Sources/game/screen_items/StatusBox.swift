enum StatusBox {
	private(set) nonisolated(unsafe) static var updateQuestBox = false
	static var quests: [Quest] {
		Game.player.quests
	}

	nonisolated(unsafe) static var showStatusBox = true {
		didSet {
			if showStatusBox {
				statusBox()
			} else {
				clear()
			}
		}
	}

	static var playerInfoStartX: Int { startX + 2 }
	static var playerInfoStartY: Int { startY + 1 }

	static var questAreaStartX: Int { startX + 2 }
	private(set) nonisolated(unsafe) static var questAreaStartY: Int = startY + 1

	static func questBoxUpdate() {
		updateQuestBox = true
	}

	static func statusBox() {
		updateQuestBox = false
		clear()
		sides()
		playerInfoArea()
		questArea()
		inventoryArea()
	}

	static func playerInfoArea() {
		if !(Game.player.name == "") {
			Screen.print(x: playerInfoStartX, y: playerInfoStartY, "\(Game.player.name):".styled(with: .bold))
		}
		#if DEBUG
			Game.player.stats.blacksmithSkillLevel = .ten
			Game.player.stats.miningSkillLevel = .ten
			Game.player.stats.builderSkillLevel = .ten
			Game.player.stats.huntingSkillLevel = .ten
			Game.player.stats.inventorSkillLevel = .ten
			Game.player.stats.stableSkillLevel = .ten
			Game.player.stats.farmingSkillLevel = .ten
			Game.player.stats.medicalSkillLevel = .ten
			Game.player.stats.carpentrySkillLevel = .ten
			Game.player.stats.cookingSkillLevel = .ten
		#endif
		var yValueToPrint = playerInfoStartY + 1
		for skillLevel in AllSkillLevels.allCases {
			if skillLevel.stat.rawValue > 0 {
				var count = ""
				for _ in 0 ..< skillLevel.stat.rawValue {
					count += "#"
				}
				Screen.print(x: playerInfoStartX + 1, y: yValueToPrint, "\(skillLevel.name): \(count)")
				yValueToPrint += 1
			}
		}
		questAreaStartY = yValueToPrint + 1
	}

	static func questArea() {
		Screen.print(x: questAreaStartX, y: questAreaStartY, "Quests:".styled(with: .bold))
		let maxVisibleLines = height - 2
		var renderedLines: [String] = []
		#if DEBUG
			Game.player.addQuest(.mine1)
			Game.player.addQuest(.mine2)
			Game.player.addQuest(.mine3)
			Game.player.addQuest(.mine4)
			Game.player.addQuest(.mine5)
			Game.player.addQuest(.mine6)
			Game.player.addQuest(.mine7)
			Game.player.addQuest(.mine8)
			Game.player.addQuest(.mine9)
			Game.player.addQuest(.mine10)
		#endif
		for (index, quest) in quests.enumerated() {
			let number = "\(index + 1)".styled(with: .bold)
			let text = "\(number). \(quest.label)"
			renderedLines.append(contentsOf: text.wrappedWithStyles(toWidth: width - 2))
		}

		if renderedLines.count > maxVisibleLines {
			renderedLines = Array(renderedLines.suffix(maxVisibleLines))
		}

		var currentY = questAreaStartY + 1
		for line in renderedLines {
			Screen.print(x: questAreaStartX + 1, y: currentY, line)
			currentY += 1
		}
	}

	static func inventoryArea() {}

	static func sides() {
		Screen.print(x: startX, y: startY, String(repeating: Screen.horizontalLine, count: width + 1))
		for y in (startY + 1) ..< endY {
			Screen.print(x: startX, y: y, Screen.verticalLine)
			Screen.print(x: endX, y: y, Screen.verticalLine)
		}
		Screen.print(x: startX + 2, y: endY, String(repeating: Screen.horizontalLine, count: width - 2))
	}

	static func clear() {
		let spaceString = String(repeating: " ", count: width - 2)
		for y in (startY + 1) ..< endY {
			Screen.print(x: startX + 2, y: y, spaceString)
		}
	}

	static func quest(_ quest: Quest) {
		clear()
		Game.player.addQuest(quest)
		statusBox()
	}

	static func removeQuest(quest: Quest) {
		clear()
		Game.player.removeQuest(quest: quest)
		statusBox()
	}

	static func removeQuest(index: Int) {
		clear()
		Game.player.removeQuest(index: index)
		statusBox()
	}

	@discardableResult
	static func removeLastQuest() -> Quest {
		Game.player.removeLastQuest()
	}

	static func updateLastQuest(newQuest: Quest) {
		Game.player.updateLastQuest(newQuest: newQuest)
		statusBox()
	}
}
