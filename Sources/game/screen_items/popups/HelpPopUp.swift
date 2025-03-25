import Foundation

class HelpPopUp: PopUp {
	var longestXLine: Int = 0
	private nonisolated(unsafe) var selectedOptionIndex = 0
	var title: String = "Help"
	var startY: Int = 3
	var showBuiler: Bool

	init(showBuiler: Bool = true) {
		self.showBuiler = showBuiler
	}

	func content(yStart: inout Int) async {
		(yStart, longestXLine) = print(y: yStart, "Normal mode:".styled(with: .bold))
		if await Game.shared.config.wasdKeys {
			(yStart, longestXLine) = print(y: yStart, "Use \(KeyboardKeys.w.render)\(KeyboardKeys.a.render)\(KeyboardKeys.s.render)\(KeyboardKeys.d.render) keys to move around")
		} else if await Game.shared.config.vimKeys {
			(yStart, longestXLine) = print(y: yStart, "Use \(KeyboardKeys.h.render)\(KeyboardKeys.j.render)\(KeyboardKeys.k.render)\(KeyboardKeys.l.render) keys to move around")
		} else if await Game.shared.config.arrowKeys {
			(yStart, longestXLine) = print(y: yStart, "Use the \("arrow keys".styled(with: .bold)) to move around")
		}
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.space.render) or \(KeyboardKeys.enter.render) to interact with objects")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.Q.render) to quit")

		(yStart, longestXLine) = print(y: yStart, "")
		(yStart, longestXLine) = print(y: yStart, "Inventory mode:".styled(with: [.bold, .yellow]))
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.i.render) to open your inventory")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.up.render) or \(KeyboardKeys.down.render) to cycle through items")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.tab.render) and \(KeyboardKeys.back_tab.render) to cycle through items")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.d.render) to destroy an item")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.questionMark.render) for help")
		if showBuiler {
			(yStart, longestXLine) = print(y: yStart, "")
			(yStart, longestXLine) = print(y: yStart, "Build mode:".styled(with: [.bold, .blue]))
			(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.b.render) to enter build mode")
			(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.e.render) to destroy")
			(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.tab.render) and \(KeyboardKeys.back_tab.render) to cycle through buildable items")
			(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.questionMark.render) for help")
		}
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.zero.render) to reload the UI")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.esc.render) to exit any mode")
		(yStart, longestXLine) = print(y: yStart, "Press \(KeyboardKeys.W.render) or \(KeyboardKeys.S.render) to scroll up and down in the message box")

		(yStart, longestXLine) = print(y: yStart, "")
		(yStart, longestXLine) = print(y: yStart, "Press any key to leave.")
		Screen.print(x: Screen.columns - 1 - Game.version.count, y: Screen.rows - 1, Game.version)

		await drawBorders(endY: yStart + 2, longestXLine: longestXLine)

		_ = TerminalInput.readKey()
	}
}
