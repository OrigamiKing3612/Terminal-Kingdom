import Foundation

class HelpPopUp: PopUp {
	var longestXLine: Int = 0
	private nonisolated(unsafe) var selectedOptionIndex = 0

	func render() async {
		let text = "Help"
		let y = 3
		Screen.print(x: Self.middleX - (text.count / 2), y: y, text.styled(with: .bold))
		var yStart = 6
		// TODO: change depending on user's config
		(yStart, longestXLine) = print(y: yStart, "Press \("wasd".styled(with: .bold)) or the \("arrow keys".styled(with: .bold)) to move.")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.space.render) or \(KeyboardKeys.enter.render) to interact with the tile you are on. ")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.i.render) to open the inventory.")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.b.render) to start building.")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.zero.render) to resize the screen.")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.W.render) and \(KeyboardKeys.S.render) to scroll up and down in the message box.")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.Q.render) to quit.")

		(yStart, longestXLine) = print(y: yStart, "Press any key to leave.")
		Screen.print(x: Screen.columns - 1 - Game.version.count, y: Screen.rows - 1, Game.version)

		await drawBorders(endY: yStart + 2, longestXLine: longestXLine)

		_ = TerminalInput.readKey()
	}
}
