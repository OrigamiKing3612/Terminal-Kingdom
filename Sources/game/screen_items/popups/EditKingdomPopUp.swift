import Foundation

class EditKingdomPopUp: TypablePopup {
	var longestXLine: Int = 0
	private nonisolated(unsafe) var selectedIndex = 0
	var isEditing: Bool = false
	var input: String = ""
	var title: String
	var kingdom: Kingdom

	init() async {
		self.kingdom = await Game.shared.kingdom
		self.title = await "Editing \(kingdom.name)"
	}

	func content(y: Int) async {
		while true {
			if isEditing {
				await textInput {
					await Game.shared.renameKingdom(newName: input)
				}
				continue
			}
			var yStart = y
			let options: [MessageOption] = [
				.init(label: "Rename", action: {
					self.input = await self.kingdom.name
					self.isEditing = true
				}),
			]
			var lastIndex = options.count - 1
			for (index, option) in options.enumerated() {
				yStart = await print(y: yStart, index: index, option.label)
				lastIndex = index
			}

			let skip = lastIndex + 1
			yStart = await print(y: yStart, index: lastIndex + 2, "Quit")
			await drawBorders(endY: yStart + 2, longestXLine: longestXLine)

			let key = TerminalInput.readKey()
			switch key {
				case .up, .w, .k, .back_tab:
					selectedIndex = max(0, selectedIndex - 1)
					if selectedIndex == skip {
						selectedIndex = selectedIndex - 1
					}
				case .down, .s, .j, .tab:
					selectedIndex = min(SettingsScreenOptions.allCases.count - 1 + 3, selectedIndex + 1)
					if selectedIndex == skip {
						selectedIndex = selectedIndex + 1
					}
				case .enter, .space:
					if selectedIndex == lastIndex + 2 {
						return
					} else {
						await options[selectedIndex].action()
					}
				default:
					break
			}
		}
	}

	private func print(y: Int, index: Int, _ text: String) async -> Int {
		let isSelected = selectedIndex == index
		let textToPrint = await "\(isSelected ? "\(Game.shared.config.icons.selectedIcon) " : "  ")\(text)"

		Screen.print(x: Self.middleX - (textToPrint.withoutStyles.count / 2), y: y, textToPrint.styled(with: .bold, styledIf: isSelected))

		if textToPrint.withoutStyles.count > longestXLine {
			longestXLine = textToPrint.withoutStyles.count
		}
		return y + 1
	}
}
