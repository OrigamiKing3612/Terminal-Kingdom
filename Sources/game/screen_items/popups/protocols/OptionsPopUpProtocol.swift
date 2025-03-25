import Foundation

protocol OptionsPopUpProtocol: PopUp, AnyObject {
	var selectedOptionIndex: Int { get set }
	var options: [MessageOption] { get }

	func content(yStart: inout Int) async
	func input(skip: Int, lastIndex: Int, shouldExit: inout Bool) async
	func before() async -> Bool
}

extension OptionsPopUpProtocol {
	func print(y: Int, index: Int, _ text: String) async -> Int {
		let isSelected = selectedOptionIndex == index
		let textToPrint = await "\(isSelected ? "\(Game.shared.config.icons.selectedIcon) " : "  ")\(text)"

		Screen.print(x: Self.middleX - (textToPrint.withoutStyles.count / 2), y: y, textToPrint.styled(with: .bold, styledIf: isSelected))

		longestXLine = max(longestXLine, text.withoutStyles.count)
		return y + 1
	}

	func content(yStart: inout Int) async {
		await renderOptions()
	}

	func renderOptions() async {
		longestXLine = title.count
		var popupWidth: Int { longestXLine + 4 }
		let popupHeight = options.count + 10

		let startX = Self.middleX - (popupWidth / 2)

		for option in options {
			longestXLine = max(longestXLine, option.label.withoutStyles.count)
		}
		for y in 1 ... (1 + popupHeight) {
			Screen.print(x: startX, y: y, String(repeating: " ", count: popupWidth))
		}

		var yStart = 3
		Screen.print(x: Self.middleX - (title.count / 2), y: yStart, title.styled(with: .bold))

		var shouldExit = false
		while !shouldExit {
			yStart = 6

			if await before() {
				continue
			}

			var lastIndex = options.count - 1
			for (index, option) in options.enumerated() {
				yStart = await print(y: yStart, index: index, option.label)
				lastIndex = index
			}

			let skip = lastIndex + 1
			yStart = await print(y: yStart + 1, index: lastIndex + 2, "Quit")

			await drawBorders(endY: yStart + 2, longestXLine: longestXLine)

			await input(skip: skip, lastIndex: lastIndex, shouldExit: &shouldExit)
		}
	}
}
