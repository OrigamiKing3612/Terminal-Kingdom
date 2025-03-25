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

	func content(yStart: inout Int) async {}

	func input(skip: inout Int, lastIndex: Int) async {
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
