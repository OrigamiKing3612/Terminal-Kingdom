enum TitleScreen {
	nonisolated(unsafe) static var startX: Int { 0 }
	nonisolated(unsafe) static var middleX: Int { Screen.columns / 2 }
	nonisolated(unsafe) static var endX: Int { Screen.columns }

	nonisolated(unsafe) static var startY: Int { 0 }
	nonisolated(unsafe) static var middleY: Int { Screen.rows / 2 }
	nonisolated(unsafe) static var endY: Int { Screen.rows }

	nonisolated(unsafe) static var selectedOptionIndex = 0

	static func show() -> TitleScreenOptions {
		// Quickly start a new game in debug mode
		#if DEBUG
			return TitleScreenOptions.newGameOption
		#else
			selectedOptionIndex = 0
			while true {
				Screen.clear()
				let text = "Welcome to Adventure!"
				let x = middleX - (text.count / 2)
				let y = middleY - (Screen.rows / 2)
				Screen.print(x: x, y: y, text.styled(with: .bold))
				let optionsX = middleX - (text.count / 4)
				let icon = " >"

				for (index, option) in TitleScreenOptions.allCases.enumerated() {
					let isSelected = selectedOptionIndex == index
					Screen.print(x: optionsX, y: y + 3 + index, "\(isSelected ? icon : "  ")\(option.label)".styled(with: .bold, styledIf: isSelected))
				}

				let key = TerminalInput.readKey()
				switch key {
					case .enter:
						return TitleScreenOptions.allCases[selectedOptionIndex]
					case .up, .w, .k:
						selectedOptionIndex = max(0, selectedOptionIndex - 1)
					case .down, .s, .j:
						selectedOptionIndex = min(2, selectedOptionIndex + 1)
					case .q:
						endProgram()
					default:
						break
				}
			}
		#endif
	}

	enum TitleScreenOptions: CaseIterable {
		case newGameOption
		case loadGameOption
		case helpOption
		case quitOption

		var label: String {
			switch self {
				case .newGameOption:
					"New Game"
				case .loadGameOption:
					"Load Game"
				case .helpOption:
					"Help"
				case .quitOption:
					"Quit"
			}
		}

		var action: Void {
			switch self {
				case .newGameOption:
					newGame()
				case .loadGameOption:
					if loadGame() {
						// Load game
						MessageBox.message("Game can not be loaded at this time. Creating new game.", speaker: .game)
						newGame()
					} else {
						MessageBox.message("No saved game found. Creating new game.", speaker: .game)
						newGame()
					}
				case .helpOption:
					TitleScreen.help()
				case .quitOption:
					endProgram()
			}
		}
	}

	static func help() {
		let text = "Help"
		let x = middleX
		let y = middleY - (Screen.rows / 2)
		Screen.print(x: x - (text.count / 2), y: y, text.styled(with: .bold))
		printHelpMessage(x: x, y: y + 3, "Press \("wasd".styled(with: .bold)) or the \("arrow keys".styled(with: .bold)) to move.")
		printHelpMessage(x: x, y: y + 4, "Press \(KeyboardKeys.space.render) or \(KeyboardKeys.enter.render) to interact with the tile you are on.")
		printHelpMessage(x: x, y: y + 5, "Press \(KeyboardKeys.i.render) to open the inventory.")
		printHelpMessage(x: x, y: y + 6, "Press \(KeyboardKeys.zero.render) to quit.")

		printHelpMessage(x: x, y: y + 5, "Press any key to quit.")
	}

	private static func printHelpMessage(x: Int, y: Int, _ text: String) {
		Screen.print(x: x - (text.withoutStyles.count / 2), y: y, text)
	}
}
