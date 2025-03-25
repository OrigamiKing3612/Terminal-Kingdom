import Foundation

protocol TypablePopup: PopUp, AnyObject {
	var isEditing: Bool { get set }
	var input: String { get set }
}

extension TypablePopup {
	func textInput(action: () async -> Void) async {
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
					await action()
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
