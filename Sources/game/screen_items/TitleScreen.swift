enum TitleScreen {
	nonisolated(unsafe) static var startX: Int { 0 }
	nonisolated(unsafe) static var middleX: Int { Screen.columns / 2 }
	nonisolated(unsafe) static var endX: Int { Screen.columns }

	nonisolated(unsafe) static var startY: Int { 0 }
	nonisolated(unsafe) static var middleY: Int { Screen.rows / 2 }
	nonisolated(unsafe) static var endY: Int { Screen.rows }

	nonisolated(unsafe) static var selectedOptionIndex = 0
	nonisolated(unsafe) static var selectedSettingOptionIndex = 0
	nonisolated(unsafe) static var config = Config()

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
					case .up, .w, .k, .back_tab:
						selectedOptionIndex = max(0, selectedOptionIndex - 1)
					case .down, .s, .j, .tab:
						selectedOptionIndex = min(TitleScreenOptions.allCases.count - 1, selectedOptionIndex + 1)
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
				case .settingsOption:
					TitleScreen.settings()
				case .quitOption:
					endProgram()
			}
		}
	}

	enum SettingsScreenOptions: CaseIterable {
		case useNerdFontOption
		case wasdKeysOption
		case arrowKeysOption
		case vimKeysOption

		var label: String {
			switch self {
				case .useNerdFontOption:
					"Use Nerd Font"
				case .vimKeysOption:
					"Use Vim Keys for moving"
				case .arrowKeysOption:
					"Use Arrow Keys for moving"
				case .wasdKeysOption:
					"Use WASD Keys for moving"
			}
		}

		func action(config: inout Config) {
			switch self {
				case .useNerdFontOption:
					config.useNerdFont.toggle()
				case .vimKeysOption:
					config.vimKeys.toggle()
				case .arrowKeysOption:
					config.arrowKeys.toggle()
				case .wasdKeysOption:
					config.wasdKeys.toggle()
			}
		}

		func configOption() -> String {
			switch self {
				case .useNerdFontOption:
					config.useNerdFont ? "On" : "Off"
				case .vimKeysOption:
					config.vimKeys ? "On" : "Off"
				case .arrowKeysOption:
					config.arrowKeys ? "On" : "Off"
				case .wasdKeysOption:
					config.wasdKeys ? "On" : "Off"
			}
		}
	}

	static func help() {
		let text = "Help"
		let x = middleX
		let y = middleY - (Screen.rows / 2)
		Screen.print(x: x - (text.count / 2), y: y, text.styled(with: .bold))
		var yStart = 3
		// TODO: change depending on user's config
		yStart = printHelpMessage(x: x, y: y + yStart, "Press \("wasd".styled(with: .bold)) or the \("arrow keys".styled(with: .bold)) to move.")
		yStart = printHelpMessage(x: x, y: y + yStart, "Press \(KeyboardKeys.space.render) or \(KeyboardKeys.enter.render) to interact with the tile you are on.")
		yStart = printHelpMessage(x: x, y: y + yStart, "Press \(KeyboardKeys.i.render) to open the inventory.")
		yStart = printHelpMessage(x: x, y: y + yStart, "Press \(KeyboardKeys.b.render) to start building.")
		yStart = printHelpMessage(x: x, y: y + yStart, "Press \(KeyboardKeys.zero.render) to quit.")

		yStart = printHelpMessage(x: x, y: y + yStart, "Press any key to quit.")
	}

	static func settings() {
		config = Config.load()
		let text = "Settings"
		let x = middleX
		let y = middleY - (Screen.rows / 2)
		while true {
			Screen.clear()
			Screen.print(x: x - (text.count / 2), y: y, text.styled(with: .bold))
			var lastIndex = SettingsScreenOptions.allCases.count - 1
			var yStart = 3
			for (index, option) in SettingsScreenOptions.allCases.enumerated() {
				yStart = printSettingsOption(x: x, y: y + yStart, index: index, text: option.label, configOption: option.configOption())
				lastIndex = index
			}
			yStart = printSettingsOption(x: x, y: yStart + 1, index: lastIndex + 2, text: "Save and Quit", configOption: "")
			yStart = printSettingsOption(x: x, y: yStart, index: lastIndex + 3, text: "Quit", configOption: "")
			let key = TerminalInput.readKey()
			switch key {
				case .up, .w, .k, .back_tab:
					selectedSettingOptionIndex = max(0, selectedSettingOptionIndex - 1)
				case .down, .s, .j, .tab:
					selectedSettingOptionIndex = min(SettingsScreenOptions.allCases.count - 1 + 3, selectedSettingOptionIndex + 1)
				case .enter:
					if selectedSettingOptionIndex == lastIndex + 2 {
						config.write()
						Game.config = Config.load()
						return
					} else if selectedSettingOptionIndex == lastIndex + 3 {
						return
					} else {
						SettingsScreenOptions.allCases[selectedSettingOptionIndex].action(config: &config)
					}
				default:
					break
			}
		}
	}

	private static func printSettingsOption(x: Int, y: Int, index: Int, text: String, configOption: String) -> Int {
		let isSelected = selectedSettingOptionIndex == index
		let configOptionToPrint = configOption == "" ? "" : ": \(configOption)"
		Screen.print(x: x - (text.count / 2), y: y, "\(isSelected ? ">" : " ")\(text)\(configOptionToPrint)".styled(with: .bold, styledIf: isSelected))
		return y + 1
	}

	private static func printHelpMessage(x: Int, y: Int, _ text: String) -> Int {
		Screen.print(x: x - (text.withoutStyles.count / 2), y: y, text)
		return y + 1
	}
}
