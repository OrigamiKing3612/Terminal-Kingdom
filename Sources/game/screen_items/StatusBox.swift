enum StatusBox {
	private(set) nonisolated(unsafe) static var updateQuestBox = false
	static var quests: [Quest] {
		get async {
			await Game.shared.player.quests
		}
	}

	private(set) nonisolated(unsafe) static var showVillageInfo: Bool = false

	static var playerInfoStartX: Int { startX + 2 }
	static var playerInfoEndX: Int { endX }
	static var playerInfoStartY: Int { startY + 1 }

	static var questAreaStartX: Int { startX + 2 }
	private(set) nonisolated(unsafe) static var questAreaStartY: Int = startY + 1

	static var villageInfoAreaStartX: Int { startX + 2 }
	private(set) nonisolated(unsafe) static var villageInfoAreaStartY: Int = startY + 2

	static func questBoxUpdate() {
		updateQuestBox = true
	}

	static func statusBox() async {
		updateQuestBox = false
		clear()
		await sides()
		await playerInfoArea()
		await questArea()
		if showVillageInfo {
			if let id = await Game.shared.kingdom.isInsideVillage(x: Game.shared.player.position.x, y: Game.shared.player.position.y) {
				let village = await Game.shared.kingdom.get(villageID: id)
				await villageInfo(village!) // We already know there is a village
			}
		}
	}

	static func playerInfoArea() async {
		if await !(Game.shared.player.name == "") {
			await Screen.print(x: playerInfoStartX, y: playerInfoStartY, "\(Game.shared.player.name):".styled(with: .bold))
		}
		var yValueToPrint = playerInfoStartY + 1
		let longestSkillName = AllSkillLevels.allCases.map(\.name.count).max() ?? 0
		for skillLevel in AllSkillLevels.allCases {
			if await skillLevel.stat.rawValue > 0 {
				var count = ""
				let statRawValue = await skillLevel.stat.rawValue
				for _ in 0 ..< statRawValue {
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
			let text = await "\(number). \(quest.label)"
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
		villageInfoAreaStartY = currentY + 1
	}

	static func villageInfo(_ village: Village) async {
		await Screen.print(x: villageInfoAreaStartX, y: villageInfoAreaStartY, "\(village.name):".styled(with: .bold))
		let maxVisibleLines = height - 2
		var renderedLines: [String] = []
		await renderedLines.append(contentsOf: "  Population: \(village.npcsInVillage.count)".wrappedWithStyles(toWidth: width - 2))

		if renderedLines.count > maxVisibleLines {
			renderedLines = Array(renderedLines.suffix(maxVisibleLines))
		}

		var currentY = villageInfoAreaStartY + 1
		for line in renderedLines {
			Screen.print(x: villageInfoAreaStartX + 1, y: currentY, line)
			currentY += 1
		}
	}

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

	static func setShowVillageInfo(_ newValue: Bool) async {
		if showVillageInfo != newValue {
			showVillageInfo = newValue
			Task {
				await statusBox()
			}
		}
	}
}

extension StatusBox {
	private nonisolated(unsafe) static var _showStatusBox = true
	nonisolated(unsafe) static var showInventoryBox: Bool { _showStatusBox }
	static func setShowStatusBox(_ newValue: Bool) async {
		_showStatusBox = newValue
		if newValue {
			await statusBox()
		} else {
			clear()
		}
	}
}
