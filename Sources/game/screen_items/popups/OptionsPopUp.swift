import Foundation

class OptionsPopUp: OptionsPopUpProtocol {
	var longestXLine: Int = 0
	var selectedOptionIndex = 0

	var title: String
	let options: [MessageOption]

	init(title: String, options: [MessageOption]) {
		self.title = title
		self.longestXLine = title.count
		self.options = options.filter { $0.label != "Quit" }
	}

	func content(y: Int) async {
		while true {
			var lastIndex = SettingsScreenOptions.allCases.count - 1
			var yStart = 3 + y
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
					selectedOptionIndex = max(0, selectedOptionIndex - 1)
					if selectedOptionIndex == skip {
						selectedOptionIndex = selectedOptionIndex - 1
					}
				case .down, .s, .j, .tab:
					selectedOptionIndex = min(SettingsScreenOptions.allCases.count - 1 + 3, selectedOptionIndex + 1)
					if selectedOptionIndex == skip {
						selectedOptionIndex = selectedOptionIndex + 1
					}
				case .enter, .space:
					if selectedOptionIndex == lastIndex + 2 {
						return
					} else {
						await options[selectedOptionIndex].action()
						return
					}
				default:
					break
			}
		}
	}
}
