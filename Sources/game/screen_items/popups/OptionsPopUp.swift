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

	func before() async -> Bool {
		false
	}

	func input(skip: Int, lastIndex: Int, shouldExit: inout Bool) async {
		let key = TerminalInput.readKey()
		switch key {
			case .up, .w, .k, .back_tab:
				selectedOptionIndex = max(0, selectedOptionIndex - 1)
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex - 1
				}
			case .down, .s, .j, .tab:
				selectedOptionIndex = min(options.count - 1 + 2, selectedOptionIndex + 1)
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex + 1
				}
			case .enter, .space:
				if selectedOptionIndex == lastIndex + 2 {
				} else {
					await options[selectedOptionIndex].action()
				}
				shouldExit = true
			default:
				break
		}
	}
}
