import Foundation

class AddNPCPopUp: PopUp {
	var startY: Int = 3

	var longestXLine: Int = 0
	var selectedOptionIndex = 0

	var title: String
	let npcs: [NPC]
	// let options: [MessageOption]
	let village: Village
	let boxLength = 20
	let boxHeight = 30

	init(village: Village) {
		self.title = "Add NPC"
		self.longestXLine = title.count
		self.village = village
		self.npcs = NPC.randomNPC(village: village, count: 3)
		// self.options = npcs.map { npc in
		// 	MessageOption(label: npc.name, action: {
		// 		await Game.shared.npcs.add(npc: npc)
		// 		await Game.shared.kingdom.add(npcID: npc.id, villageID: village.id)
		// 	})
		// }
	}

	func before() async -> Bool {
		false
	}

	func content(yStart: inout Int) async {
		assert(npcs.count == 3, "Expected exactly 3 NPCs")
		longestXLine = title.count
		// var popupWidth: Int { longestXLine + 4 }
		// let popupHeight = options.count + 10

		// let startX = Self.middleX - (popupWidth / 2)
		//
		// for option in options {
		// 	longestXLine = max(longestXLine, option.label.withoutStyles.count)
		// }
		// for y in 1 ... (1 + popupHeight) {
		// 	Screen.print(x: startX, y: y, String(repeating: " ", count: popupWidth))
		// }

		var yStart = 3
		Screen.print(x: Self.middleX - (title.count / 2), y: yStart, title.styled(with: .bold))

		var shouldExit = false
		while !shouldExit {
			yStart = 6

			if await before() {
				continue
			}

			// var lastIndex = options.count - 1
			let startY = 6
			let box1X = Self.middleX - boxLength - 5
			let box2X = Self.middleX
			let box3X = Self.middleX + boxLength + 5

			await drawNPCBox(x: box1X, npc: npcs[0])
			await drawNPCBox(x: box2X, npc: npcs[1])
			await drawNPCBox(x: box3X, npc: npcs[2])

			// if options.isEmpty {
			// 	selectedOptionIndex = lastIndex + 2
			// }

			// let skip = lastIndex + 1
			// (yStart, xStart) = await print(x: x, y: yStart + 1, index: lastIndex + 2, "Quit")

			// await drawBorders(endY: yStart + 2, longestXLine: longestXLine)

			// await input(skip: skip, lastIndex: lastIndex, shouldExit: &shouldExit)
			let key = TerminalInput.readKey()
		}
	}

	func input(skip: Int, lastIndex: Int, shouldExit: inout Bool) async {
		let key = TerminalInput.readKey()
		switch key {
			case .up, .w, .k, .back_tab, .h, .left:
				selectedOptionIndex = max(0, selectedOptionIndex - 1)
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex - 1
				}
			case .down, .s, .j, .tab, .l, .right:
				// selectedOptionIndex = min(options.count - 1 + 2, selectedOptionIndex + 1)
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex + 1
				}
			case .enter, .space:
				if selectedOptionIndex == lastIndex + 2 {
				} else {
					// await options[selectedOptionIndex].action()
				}
				shouldExit = true
			//! TODO: Add for all other popups
			case .esc:
				shouldExit = true
			default:
				break
		}
	}

	func drawNPCBox(x: Int, npc: NPC) async {
		let verticalLine = await Game.shared.verticalLine
		let horizontalLine = await Game.shared.horizontalLine
		let topLeftCorner = await Game.shared.topLeftCorner
		let topRightCorner = await Game.shared.topRightCorner
		let bottomLeftCorner = await Game.shared.bottomLeftCorner
		let bottomRightCorner = await Game.shared.bottomRightCorner
		Screen.print(x: x, y: 1, topLeftCorner + String(repeating: horizontalLine, count: boxLength - 2) + topRightCorner)
		for y in 2 ..< boxHeight {
			Screen.print(x: x, y: y, verticalLine + String(repeating: " ", count: boxLength - 2) + verticalLine)
		}
		Screen.print(x: x, y: boxHeight, bottomLeftCorner + String(repeating: horizontalLine, count: boxLength - 2) + bottomRightCorner)
	}
}
