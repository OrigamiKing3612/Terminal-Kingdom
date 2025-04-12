import Foundation

class TypingPopUp: TypablePopup {
	var longestXLine: Int
	var title: String
	var isEditing: Bool = false
	var input: String
	var action: (_ input: String) async -> Void
	var startY: Int

	//! TODO: clear after use
	init(title: String, longestXLine: Int, input: String, startY: Int, action: @escaping (_ input: String) async -> Void) async {
		self.title = title
		self.longestXLine = longestXLine
		self.action = action
		self.startY = startY
		self.input = input
	}

	func content(yStart: inout Int) async {
		yStart = startY
		isEditing = true
		await drawBorders(endY: yStart + 3, longestXLine: longestXLine)
		await textInput(y: yStart) {
			await action(input)
		}
	}

	private func textInput(y: Int, action: () async -> Void) async {
		while isEditing {
			let displayText = " \(input) "
			Screen.print(x: Self.middleX - (displayText.count / 2), y: y + 2, displayText.styled(with: .bold))

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
					await action()
				}
				isEditing = false
				return
			} else if key == .esc {
				isEditing = false
			}

			if input.count > 20 {
				input.removeLast()
			}
		}
	}
}
