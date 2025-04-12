import Foundation

class EditKingdomPopUp: OptionsPopUpProtocol {
	var longestXLine: Int = 0
	var title: String
	var kingdom: Kingdom
	var selectedOptionIndex: Int = 0
	var options: [MessageOption]
	var startY: Int = 3

	init() async {
		self.kingdom = await Game.shared.kingdom
		self.title = await "Editing \(kingdom.name)"
		self.options = []
	}

	private func rename() async {
		await Screen.popUp(TypingPopUp(title: "Rename \(kingdom.name)", longestXLine: longestXLine, input: kingdom.name, startY: options.count + 16) { input in
			await Game.shared.renameKingdom(newName: input)
		})
		kingdom = await Game.shared.kingdom
	}

	func before() async -> Bool {
		options = [
			.init(label: "Rename", action: rename),
		]
		return false
	}

	func input(skip: Int, lastIndex: Int, shouldExit: inout Bool) async {
		let key = TerminalInput.readKey()
		let totalOptions = options.count - 1 + 3
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
					shouldExit = true
				} else {
					await options[selectedOptionIndex].action()
				}
			case .esc:
				shouldExit = true
			default:
				break
		}
	}
}
