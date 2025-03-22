import Foundation

class EditVillagePopUp: PopUp {
	var longestXLine: Int = 0
	private nonisolated(unsafe) var selectedIndex = 0
	private var isEditing = false
	private var input = ""
	private var village: Village

	init(village: Village) {
		self.village = village
	}

	func render() async {
		let text = await "Editing \(village.name)"
		longestXLine = text.count
		let x = EditVillagePopUp.middleX
		let y = 3
		Screen.print(x: x - (text.count / 2), y: y, text.styled(with: .bold))

		while true {
			if isEditing {
				await textInput()
				continue
			}
			var yStart = y + 3
			let options: [MessageOption] = [
				.init(label: "Rename", action: {
					self.input = await self.village.name
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
				case .enter:
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

	private func textInput() async {
		while isEditing {
			let displayText = " \(input) "
			Screen.print(x: Self.middleX - (displayText.count / 2), y: 9, displayText.styled(with: .bold))

			let key = TerminalInput.readKey()
			if key.isLetter {
				input += key.rawValue
			} else if key == .space {
				input += " "
			} else if key == .backspace {
				if !input.isEmpty {
					input.removeLast()
				}
			} else if key == .enter {
				if !input.isEmpty {
					await Game.shared.kingdom.renameVillage(id: village.id, name: input)
				}
				isEditing = false
				return
			}

			if input.count > 20 {
				input.removeLast()
			}
		}
	}
}
