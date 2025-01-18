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
	static var playerInfoEndX: Int { endX }
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
		var yValueToPrint = playerInfoStartY + 1
		let longestSkillName = AllSkillLevels.allCases.map(\.name.count).max() ?? 0
		for skillLevel in AllSkillLevels.allCases {
			if skillLevel.stat.rawValue > 0 {
				var count = ""
				for _ in 0 ..< skillLevel.stat.rawValue {
					count += "#"
				}
				let spaces = String(repeating: " ", count: longestSkillName - skillLevel.name.count)
				Screen.print(x: playerInfoStartX + 1, y: yValueToPrint, "\(skillLevel.name): \(spaces)\(count)")
				yValueToPrint += 1
			}
		}
		questAreaStartY = yValueToPrint + 1
	}

	static func position() {
		if MapBox.mapType == .mainMap {
			let text = "  x: \(Game.player.position.x); y: \(Game.player.position.y)"
			Screen.print(x: playerInfoEndX - text.count, y: playerInfoStartY, text)
		}
	}

	static func questArea() {
		Screen.print(x: questAreaStartX, y: questAreaStartY, "Quests:".styled(with: .bold))
		let maxVisibleLines = height - 2
		var renderedLines: [String] = []
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
		Screen.print(x: startX, y: startY, String(repeating: Game.horizontalLine, count: width + 1))
		for y in (startY + 1) ..< endY {
			Screen.print(x: startX, y: y, Game.verticalLine)
			Screen.print(x: endX, y: y, Game.verticalLine)
		}
		Screen.print(x: startX + 2, y: endY, String(repeating: Game.horizontalLine, count: width - 2))
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
