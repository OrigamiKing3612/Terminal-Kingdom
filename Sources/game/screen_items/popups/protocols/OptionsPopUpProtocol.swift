import Foundation

protocol OptionsPopUpProtocol: PopUp, AnyObject {
	var selectedOptionIndex: Int { get set }
}

extension OptionsPopUpProtocol {
	func print(y: Int, index: Int, _ text: String) async -> Int {
		let isSelected = selectedOptionIndex == index
		let textToPrint = await "\(isSelected ? "\(Game.shared.config.icons.selectedIcon) " : "  ")\(text)"

		Screen.print(x: Self.middleX - (textToPrint.withoutStyles.count / 2), y: y, textToPrint.styled(with: .bold, styledIf: isSelected))

		longestXLine = max(longestXLine, text.withoutStyles.count)
		return y + 1
	}
}
