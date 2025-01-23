enum StatusBox {
	private(set) nonisolated(unsafe) static var updateQuestBox = false
	static var quests: [Quest] {
		get async {
			await Game.shared.player.quests
		}
	}

	//! TODO: this will probably break stuff
	nonisolated(unsafe) static var showStatusBox = true {
		didSet {
			if showStatusBox {
				Task {
					await statusBox()
				}
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

	static func statusBox() async {
		updateQuestBox = false
		await clear()
		await sides()
		await playerInfoArea()
		await questArea()
		await inventoryArea()
	}

	static func playerInfoArea() async {
		if await !(Game.shared.player.name == "") {
			await Screen.print(x: playerInfoStartX, y: playerInfoStartY, "\(Game.shared.player.name):".styled(with: .bold))
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

	static func position() async {
		if await MapBox.mapType == .mainMap {
			let text = await " \(Game.shared.player.direction.render) x: \(Game.shared.player.position.x); y: \(Game.shared.player.position.y)"
			Screen.print(x: playerInfoEndX - text.count, y: playerInfoStartY, text)
		}
	}

	static func questArea() async {
		Screen.print(x: questAreaStartX, y: questAreaStartY, "Quests:".styled(with: .bold))
		let maxVisibleLines = height - 2
		var renderedLines: [String] = []
		for (index, quest) in await quests.enumerated() {
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

	static func sides() async {
		await Screen.print(x: startX, y: startY, String(repeating: Game.shared.horizontalLine, count: width + 1))
		for y in (startY + 1) ..< endY {
			await Screen.print(x: startX, y: y, Game.shared.verticalLine)
			await Screen.print(x: endX, y: y, Game.shared.verticalLine)
		}
		await Screen.print(x: startX + 2, y: endY, String(repeating: Game.shared.horizontalLine, count: width - 2))
	}

	static func clear() {
		let spaceString = String(repeating: " ", count: width - 2)
		for y in (startY + 1) ..< endY {
			Screen.print(x: startX + 2, y: y, spaceString)
		}
	}

	static func quest(_ quest: Quest) async {
		clear()
		await Game.shared.player.addQuest(quest)
		await statusBox()
	}

	static func removeQuest(quest: Quest) async {
		clear()
		await Game.shared.player.removeQuest(quest: quest)
		await statusBox()
	}

	static func removeQuest(index: Int) async {
		clear()
		await Game.shared.player.removeQuest(index: index)
		await statusBox()
	}

	@discardableResult
	static func removeLastQuest() async -> Quest {
		await Game.shared.player.removeLastQuest()
	}

	static func updateLastQuest(newQuest: Quest) async {
		await Game.shared.player.updateLastQuest(newQuest: newQuest)
		await statusBox()
	}
}
