import Foundation

class OptionsPopUp: OptionsPopUpProtocol {
	var startY: Int = 3

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
		let totalOptions = options.count - 1 + 2

		switch key {
			case .up, .left, .w, .k, .h, .back_tab:
				if selectedOptionIndex > 0 {
					selectedOptionIndex -= 1
				} else {
					selectedOptionIndex = totalOptions
				}
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex - 1
				}
			case .down, .right, .s, .j, .l, .tab:
				if selectedOptionIndex < totalOptions {
					selectedOptionIndex += 1
				} else {
					selectedOptionIndex = 0
				}
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex + 1
				}
			case .enter, .space:
				if selectedOptionIndex == lastIndex + 2 {
				} else {
					await options[selectedOptionIndex].action()
				}
				shouldExit = true
			case .esc:
				shouldExit = true
			default:
				break
		}
	}
}
