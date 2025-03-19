import Foundation

class HelpPopUp: PopUp {
	var longestXLine: Int = 0

	func render() async {
		let text = "Help"
		let x = HelpPopUp.middleX
		let y = 3
		Screen.print(x: x - (text.count / 2), y: y, text.styled(with: .bold))
		var yStart = 6
		// TODO: change depending on user's config
		yStart = printHelpMessage(x: x, y: yStart, "Press \("wasd".styled(with: .bold)) or the \("arrow keys".styled(with: .bold)) to move.")
		yStart = printHelpMessage(x: x, y: yStart, "Press \(KeyboardKeys.space.render) or \(KeyboardKeys.enter.render) to interact with the tile you are on.")
		yStart = printHelpMessage(x: x, y: yStart, "Press \(KeyboardKeys.i.render) to open the inventory.")
		yStart = printHelpMessage(x: x, y: yStart, "Press \(KeyboardKeys.b.render) to start building.")
		yStart = printHelpMessage(x: x, y: yStart, "Press \(KeyboardKeys.zero.render) to resize the screen.")
		yStart = printHelpMessage(x: x, y: yStart, "Press \(KeyboardKeys.W.render) and \(KeyboardKeys.S.render) to scroll up and down in the message box.")
		yStart = printHelpMessage(x: x, y: yStart, "Press \(KeyboardKeys.Q.render) to quit.")

		yStart = printHelpMessage(x: x, y: yStart, "Press any key to leave.")
		Screen.print(x: Screen.columns - 1 - Game.version.count, y: Screen.rows - 1, Game.version)

		await drawBorders(x: x, endY: yStart + 2)

		_ = TerminalInput.readKey()
	}

	private func printHelpMessage(x: Int, y: Int, _ text: String) -> Int {
		Screen.print(x: x - (text.withoutStyles.count / 2), y: y, text)
		if text.withoutStyles.count > longestXLine {
			longestXLine = text.withoutStyles.count
		}
		return y + 1
	}

	private func drawBorders(x: Int, endY: Int) async {
		longestXLine += 2
		for y in 0 ... endY + 1 {
			await Screen.print(x: x - (longestXLine / 2), y: 0 + y, Game.shared.verticalLine)

			await Screen.print(x: x + (longestXLine / 2) - 1, y: 0 + y, Game.shared.verticalLine)
		}
		await Screen.print(x: x - (longestXLine / 2), y: 0, String(repeating: Game.shared.horizontalLine, count: longestXLine))

		await Screen.print(x: x - (longestXLine / 2), y: endY + 2, String(repeating: Game.shared.horizontalLine, count: longestXLine))
	}
}
