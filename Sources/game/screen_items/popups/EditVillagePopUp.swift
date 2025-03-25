import Foundation

class EditVillagePopUp: OptionsPopUpProtocol {
	var longestXLine: Int = 0
	private var village: Village
	var title: String
	var selectedOptionIndex = 0
	var options: [MessageOption]
	var startY: Int = 3

	init(village: Village) async {
		self.village = village
		self.title = await "Editing \(village.name)"
		self.options = []
	}

	private func rename() async {
		await Screen.popUp(TypingPopUp(title: "Rename \(village.name)", longestXLine: longestXLine, input: village.name, startY: options.count + 16) { input in
			await Game.shared.kingdom.renameVillage(id: self.village.id, name: input)
		})
		village = await Game.shared.kingdom.villages[village.id]!
	}

	func before() async -> Bool {
		options = [
			.init(label: "Rename", action: rename),
		]
		return false
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
				selectedOptionIndex = min(options.count - 1 + 3, selectedOptionIndex + 1)
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex + 1
				}
			case .enter, .space:
				if selectedOptionIndex == lastIndex + 2 {
					shouldExit = true
				} else {
					await options[selectedOptionIndex].action()
				}
			default:
				break
		}
	}
}
