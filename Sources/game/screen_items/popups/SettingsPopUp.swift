import Foundation

class SettingsPopUp: PopUp {
	var longestXLine: Int = 0
	private nonisolated(unsafe) var selectedSettingOptionIndex = 0
	private nonisolated(unsafe) var config = Config()

	func render() async {
		// TODO: reload config after saving so this isn't async
		config = await Config.load()
		let text = "Settings"
		let x = SettingsPopUp.middleX
		let y = 3
		while true {
			longestXLine = 0
			Screen.clear()
			Screen.print(x: x - (text.count / 2), y: y, text.styled(with: .bold))
			var lastIndex = SettingsScreenOptions.allCases.count - 1
			var yStart = 3 + y
			for (index, option) in SettingsScreenOptions.allCases.enumerated() {
				yStart = await printSettingsOption(x: x, y: yStart, index: index, text: option.label, configOption: option.configOption(config))
				lastIndex = index
			}

			let skip = lastIndex + 1
			yStart = await printSettingsOption(x: x, y: yStart + 1, index: lastIndex + 2, text: "Save and Quit", configOption: "")
			yStart = await printSettingsOption(x: x, y: yStart, index: lastIndex + 3, text: "Quit", configOption: "")

			await drawBorders(x: SettingsPopUp.middleX, endY: yStart + 2)

			let key = TerminalInput.readKey()
			switch key {
				case .up, .w, .k, .back_tab:
					selectedSettingOptionIndex = max(0, selectedSettingOptionIndex - 1)
					if selectedSettingOptionIndex == skip {
						selectedSettingOptionIndex = selectedSettingOptionIndex - 1
					}
				case .down, .s, .j, .tab:
					selectedSettingOptionIndex = min(SettingsScreenOptions.allCases.count - 1 + 3, selectedSettingOptionIndex + 1)
					if selectedSettingOptionIndex == skip {
						selectedSettingOptionIndex = selectedSettingOptionIndex + 1
					}
				case .enter:
					if selectedSettingOptionIndex == lastIndex + 2 {
						await config.write()
						await Game.shared.loadConfig()
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

	private func printSettingsOption(x: Int, y: Int, index: Int, text: String, configOption: String) async -> Int {
		let isSelected = selectedSettingOptionIndex == index
		let configOptionToPrint = configOption == "" ? "" : ": \(configOption)"
		let textToPrint = await "\(isSelected ? "\(Game.shared.config.icons.selectedIcon) " : "  ")\(text)\(configOptionToPrint)"

		Screen.print(x: x - (textToPrint.withoutStyles.count / 2), y: y, textToPrint.styled(with: .bold, styledIf: isSelected))

		if textToPrint.withoutStyles.count > longestXLine {
			longestXLine = textToPrint.withoutStyles.count
		}
		return y + 1
	}

	private func drawBorders(x: Int, endY: Int) async {
		longestXLine += 3
		let verticalLine = await Game.shared.verticalLine
		let horizontalLine = await Game.shared.horizontalLine
		let topLeftCorner = await Game.shared.topLeftCorner
		let topRightCorner = await Game.shared.topRightCorner
		let bottomLeftCorner = await Game.shared.bottomLeftCorner
		let bottomRightCorner = await Game.shared.bottomRightCorner

		for y in 0 ... endY + 1 {
			Screen.print(x: x - (longestXLine / 2) - 1, y: 1 + y, verticalLine)

			Screen.print(x: x + (longestXLine / 2) + 1, y: 1 + y, verticalLine)
		}
		Screen.print(x: x - (longestXLine / 2) - 1, y: 0, topLeftCorner + String(repeating: horizontalLine, count: longestXLine + 1) + topRightCorner)
		Screen.print(x: x - (longestXLine / 2) - 1, y: endY + 2, bottomLeftCorner + String(repeating: horizontalLine, count: longestXLine + 1) + bottomRightCorner)
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
