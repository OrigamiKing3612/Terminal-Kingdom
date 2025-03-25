import Foundation

class SettingsPopUp: PopUp {
	var longestXLine: Int = 0
	private var selectedOptionIndex = 0
	private var config = Config()
	var title: String = "Settings"

	func content(y: Int) async {
		// TODO: reload config after saving so this isn't async
		config = await Config.load()
		while true {
			var lastIndex = SettingsScreenOptions.allCases.count - 1
			var yStart = y
			for (index, option) in SettingsScreenOptions.allCases.enumerated() {
				yStart = await print(y: yStart, index: index, text: option.label, configOption: option.configOption(config))
				lastIndex = index
			}

			let skip = lastIndex + 1
			yStart = await print(y: yStart + 1, index: lastIndex + 2, text: "Save and Quit", configOption: "")
			yStart = await print(y: yStart, index: lastIndex + 3, text: "Quit", configOption: "")

			await drawBorders(endY: yStart + 2, longestXLine: longestXLine)

			let key = TerminalInput.readKey()
			switch key {
				case .up, .w, .k, .back_tab:
					selectedOptionIndex = max(0, selectedOptionIndex - 1)
					if selectedOptionIndex == skip {
						selectedOptionIndex = selectedOptionIndex - 1
					}
				case .down, .s, .j, .tab:
					selectedOptionIndex = min(SettingsScreenOptions.allCases.count - 1 + 3, selectedOptionIndex + 1)
					if selectedOptionIndex == skip {
						selectedOptionIndex = selectedOptionIndex + 1
					}
				case .enter, .space:
					if selectedOptionIndex == lastIndex + 2 {
						await config.write()
						await Game.shared.loadConfig()
						return
					} else if selectedOptionIndex == lastIndex + 3 {
						return
					} else {
						SettingsScreenOptions.allCases[selectedOptionIndex].action(config: &config)
					}
				default:
					break
			}
		}
	}

	private func print(y: Int, index: Int, text: String, configOption: String) async -> Int {
		let isSelected = selectedOptionIndex == index
		let configOptionToPrint = configOption == "" ? "" : ": \(configOption)"
		let textToPrint = await "\(isSelected ? "\(Game.shared.config.icons.selectedIcon) " : "  ")\(text)\(configOptionToPrint)"

		Screen.print(x: Self.middleX - (textToPrint.withoutStyles.count / 2), y: y, textToPrint.styled(with: .bold, styledIf: isSelected))

		if textToPrint.withoutStyles.count > longestXLine {
			longestXLine = textToPrint.withoutStyles.count
		}
		return y + 1
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

	func configOption(_ config: Config) -> String {
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
