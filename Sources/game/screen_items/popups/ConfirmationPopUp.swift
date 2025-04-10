import Foundation

class ConfirmationPopUp: OptionsPopUpProtocol {
	var options: [MessageOption]
	var title: String
	var message: String
	var onConfirm: () async -> Void
	var longestXLine: Int = 0
	var selectedOptionIndex: Int = 0
	var startY: Int = 3

	init(title: String, message: String, onConfirm: @escaping () async -> Void) {
		self.title = title
		self.message = message
		self.onConfirm = onConfirm
		self.longestXLine = max(title.count, message.count)
		self.options = []
	}

	func before() async -> Bool {
		options = [
			MessageOption(label: "Confirm", action: {
				await self.onConfirm()
			}),
			MessageOption(label: "Cancel", action: {}),
		]
		return false
	}

	func input(skip: Int, lastIndex: Int, shouldExit: inout Bool) async {
		let key = TerminalInput.readKey()
		switch key {
			case .up, .w, .k, .back_tab:
				selectedOptionIndex = max(0, selectedOptionIndex - 1)
			case .down, .s, .j, .tab:
				selectedOptionIndex = min(1, selectedOptionIndex + 1)
			case .enter, .space:
				if selectedOptionIndex == 0 {
					await onConfirm()
				}
				shouldExit = true
			default:
				break
		}
	}
}
