struct TitleScreen {
	private nonisolated(unsafe) var startX: Int { 0 }
	private nonisolated(unsafe) var middleX: Int { Screen.columns / 2 }
	private nonisolated(unsafe) var endX: Int { Screen.columns }

	private nonisolated(unsafe) var startY: Int { 0 }
	private nonisolated(unsafe) var middleY: Int { Screen.rows / 2 }
	private nonisolated(unsafe) var endY: Int { Screen.rows }

	private nonisolated(unsafe) var selectedOptionIndex = 0

	mutating func show() async -> TitleScreenOptions {
		// Quickly start a new game in debug mode
		#if DEBUG
			return TitleScreenOptions.newGameOption
		#else
			selectedOptionIndex = 0
			while true {
				Screen.clear()
				let text = "Welcome to Terminal Kingdom!"
				let x = middleX - (text.count / 2)
				let y = middleY - (Screen.rows / 2)
				Screen.print(x: x, y: y, text.styled(with: .bold))
				let optionsX = middleX - (text.count / 4)
				let icon = await " \(Game.shared.config.icons.selectedIcon)"

				for (index, option) in TitleScreenOptions.allCases.enumerated() {
					let isSelected = selectedOptionIndex == index
					Screen.print(x: optionsX, y: y + 3 + index, "\(isSelected ? icon : "  ")\(option.label)".styled(with: .bold, styledIf: isSelected))
				}

				let key = TerminalInput.readKey()
				switch key {
					case .enter:
						return TitleScreenOptions.allCases[selectedOptionIndex]
					case .up, .w, .k, .back_tab:
						selectedOptionIndex = max(0, selectedOptionIndex - 1)
					case .down, .s, .j, .tab:
						selectedOptionIndex = min(TitleScreenOptions.allCases.count - 1, selectedOptionIndex + 1)
					case .zero:
						Screen.clear()
						Screen.initialize()
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
		case settingsOption
		case quitOption

		var label: String {
			switch self {
				case .newGameOption:
					"New Game"
				case .loadGameOption:
					"Load Game"
				case .helpOption:
					"Help"
				case .settingsOption:
					"Settings"
				case .quitOption:
					"Quit"
			}
		}

		func action() async {
			switch self {
				case .newGameOption:
					await newGame()
				case .loadGameOption:
					if await loadGame() {
						// Load game
						await MessageBox.message("Games can not be loaded at this time. Creating new game.", speaker: .game)
						await newGame()
					} else {
						await MessageBox.message("No saved game found. Creating new game.", speaker: .game)
						await newGame()
					}
				case .helpOption:
					return
				case .settingsOption:
					return
				case .quitOption:
					endProgram()
			}
		}
	}
}
