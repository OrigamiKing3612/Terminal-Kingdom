import Foundation

protocol OptionsPopUpProtocol: PopUp, AnyObject {
	var selectedOptionIndex: Int { get set }
	var options: [MessageOption] { get }

	func input(skip: inout Int, lastIndex: Int) async
}

extension OptionsPopUpProtocol {
	func print(y: Int, index: Int, _ text: String) async -> Int {
		let isSelected = selectedOptionIndex == index
		let textToPrint = await "\(isSelected ? "\(Game.shared.config.icons.selectedIcon) " : "  ")\(text)"

		Screen.print(x: Self.middleX - (textToPrint.withoutStyles.count / 2), y: y, textToPrint.styled(with: .bold, styledIf: isSelected))

		longestXLine = max(longestXLine, text.withoutStyles.count)
		return y + 1
	}

	func render() async {
		longestXLine = title.count
		var yStart = 3
		Screen.print(x: Self.middleX - (title.count / 2), y: yStart, title.styled(with: .bold))
		while true {
			yStart = 6
			var lastIndex = SettingsScreenOptions.allCases.count - 1
			for (index, option) in options.enumerated() {
				yStart = await print(y: yStart, index: index, option.label)
				lastIndex = index
			}

			var skip = lastIndex + 1
			yStart = await print(y: yStart, index: lastIndex + 2, "Quit")

			await drawBorders(endY: yStart + 2, longestXLine: longestXLine)
			await input(skip: &skip, lastIndex: lastIndex)
		}
	}
}
