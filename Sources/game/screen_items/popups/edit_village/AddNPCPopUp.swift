import Foundation

class AddNPCPopUp: PopUp {
	var startY: Int = 4

	var longestXLine: Int = 0
	var selectedOptionIndex = 0

	var title: String
	let npcs: [NPC]
	// let options: [MessageOption]
	let village: Village
	let boxLength = 30
	let boxHeight = 15

	init(village: Village) {
		self.title = "Add NPC"
		self.longestXLine = title.count
		self.village = village
		self.npcs = NPC.randomNPC(village: village, count: 3)
	}

	func before() async -> Bool {
		false
	}

	func content(yStart: inout Int) async {
		assert(npcs.count == 3, "Expected exactly 3 NPCs")

		let box1X = Self.middleX - boxLength - 5
		let box2X = Self.middleX
		let box3X = Self.middleX + boxLength + 5

		await selfDrawBorders(box1X: box1X, box3X: box3X)
		let d = box2X + boxLength / 2 - title.count / 2

		var shouldExit = false
		while !shouldExit {
			if await before() {
				continue
			}
			Screen.print(x: d, y: 3, title.styled(with: .bold))
			Screen.print(x: box1X - 2 + 1, y: 4, "Select an NPC to add to your village")
			Screen.print(x: box1X - 2 + 1, y: 5, "Press \(KeyboardKeys.esc.render) to leave")

			await drawNPCBox(x: box1X, npc: npcs[0], index: 0)
			await drawNPCBox(x: box2X, npc: npcs[1], index: 1)
			await drawNPCBox(x: box3X, npc: npcs[2], index: 2)

			await input(shouldExit: &shouldExit)
		}
	}

	func input(shouldExit: inout Bool) async {
		let key = TerminalInput.readKey()
		let totalOptions = npcs.count - 1
		switch key {
			case .up, .left, .w, .k, .h, .back_tab:
				if selectedOptionIndex > 0 {
					selectedOptionIndex -= 1
				} else {
					selectedOptionIndex = totalOptions
				}
			case .down, .right, .s, .j, .l, .tab:
				if selectedOptionIndex < totalOptions {
					selectedOptionIndex += 1
				} else {
					selectedOptionIndex = 0
				}
			case .enter, .space:
				guard let courthouse = await Game.shared.kingdom.villages[village.id]?.getCourthouse() else { return }
				guard let customMap = await Game.shared.maps.customMaps[courthouse.id] else { return }

				for (y, row) in customMap.grid.enumerated() {
					for (x, tile) in row.enumerated() {
						if case .plain = tile.type { continue }
						await Game.shared.npcs.add(npc: npcs[selectedOptionIndex])
						let oldTile = customMap.grid[y][x]
						let newTile = MapTile(type: .npc(tile: .init(npc: npcs[selectedOptionIndex])), event: .talkToNPC, biome: oldTile.biome)
						await MapBox.updateTile(newTile: newTile, x: x, y: y)
						await Game.shared.kingdom.add(npcID: npcs[selectedOptionIndex].id, villageID: village.id)
						shouldExit = true
						return
					}
				}
				shouldExit = true
			case .esc:
				shouldExit = true
			default:
				break
		}
	}

	func drawNPCBox(x: Int, npc: NPC, index: Int) async {
		let yStart = 6
		let verticalLine = await Game.shared.verticalLine.styled(with: [.bold, .purple], styledIf: selectedOptionIndex == index)
		let horizontalLine = await Game.shared.horizontalLine.styled(with: [.bold, .purple], styledIf: selectedOptionIndex == index)
		let topLeftCorner = await Game.shared.topLeftCorner.styled(with: [.bold, .purple], styledIf: selectedOptionIndex == index)
		let topRightCorner = await Game.shared.topRightCorner.styled(with: [.bold, .purple], styledIf: selectedOptionIndex == index)
		let bottomLeftCorner = await Game.shared.bottomLeftCorner.styled(with: [.bold, .purple], styledIf: selectedOptionIndex == index)
		let bottomRightCorner = await Game.shared.bottomRightCorner.styled(with: [.bold, .purple], styledIf: selectedOptionIndex == index)
		Screen.print(x: x, y: yStart + 1, "\(topLeftCorner + String(repeating: horizontalLine, count: boxLength - 2) + topRightCorner)")
		for y in 2 ..< boxHeight {
			Screen.print(x: x, y: y + yStart, "\(verticalLine + String(repeating: " ", count: boxLength - 2) + verticalLine)")
		}
		Screen.print(x: x, y: yStart + boxHeight, "\(bottomLeftCorner + String(repeating: horizontalLine, count: boxLength - 2) + bottomRightCorner)")

		Screen.print(x: x + 1, y: yStart + 2, "\(npc.name):".styled(with: .bold))
		Screen.print(x: x + 1, y: yStart + 3, "Age: \(npc.age)")
		let skills = npc.skill.allSkills().filter { $0.1 != .none }
		if !skills.isEmpty {
			Screen.print(x: x + 1, y: yStart + 4, "Skill:")
			var skillY = 5
			for (skillName, skillLevel) in skills {
				Screen.print(x: x + 2, y: yStart + skillY, "\(skillName): \(skillLevel.name)")
				skillY += 1
			}
		}
		// Screen.print(x: x, y: yStart + 6, "")
	}

	func selfDrawBorders(box1X: Int, box3X: Int) async {
		let yStart = 1

		let verticalLine = await Game.shared.verticalLine
		let horizontalLine = await Game.shared.horizontalLine
		let topLeftCorner = await Game.shared.topLeftCorner
		let topRightCorner = await Game.shared.topRightCorner
		let bottomLeftCorner = await Game.shared.bottomLeftCorner
		let bottomRightCorner = await Game.shared.bottomRightCorner
		let d = Int(abs(Double(box1X - (box3X + boxLength)))) + 2

		Screen.print(x: box1X - 2, y: yStart + 1, topLeftCorner + String(repeating: horizontalLine, count: d) + topRightCorner)

		for y in 2 ... boxHeight + 5 {
			Screen.print(x: box1X - 2, y: y + yStart, "\(verticalLine + String(repeating: " ", count: d) + verticalLine)")
		}
		Screen.print(x: box1X - 2 + 1, y: yStart + 5, String(repeating: horizontalLine, count: d))

		Screen.print(x: box1X - 2, y: yStart + boxHeight + 6, bottomLeftCorner + String(repeating: horizontalLine, count: d) + bottomRightCorner)
	}
}
