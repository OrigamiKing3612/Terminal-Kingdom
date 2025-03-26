extension String {
	func styled(with textStyles: [TextStyles], styledIf: Bool = true) -> String {
		if Config.useColors == false {
			return self
		}
		var newString = self
		for textStyle in textStyles {
			newString = "\(textStyle.render)\(newString)"
		}
		return styledIf ? "\(newString)\(TextStyles.resetAll.render)" : self
	}

	func styled(with textStyle: TextStyles, styledIf: Bool = true) -> String {
		styled(with: [textStyle], styledIf: styledIf)
	}

	var withoutStyles: String {
		replacingOccurrences(of: "\u{1B}\\[[0-9;]*[a-zA-Z]", with: "", options: .regularExpression)
	}

	func wrappedWithStyles(toWidth width: Int) -> [String] {
		var words = split(separator: " ", omittingEmptySubsequences: false)
		var lines: [String] = []
		var currentLine = ""
		var currentLineVisibleWidth = 0

		while !words.isEmpty {
			let word = words.first!
			let wordWithoutStyles = String(word).withoutStyles

			if currentLineVisibleWidth + wordWithoutStyles.count + (currentLine.isEmpty ? 0 : 1) <= width {
				// Add space if it's not the first word
				if !currentLine.isEmpty {
					currentLine.append(" ")
					currentLineVisibleWidth += 1
				}
				currentLine += word
				currentLineVisibleWidth += wordWithoutStyles.count
				words.removeFirst()
			} else {
				// If the word itself is too long, split it
				if wordWithoutStyles.count > width {
					let splitIndex = width - currentLineVisibleWidth
					let remainingPart = String(word.dropFirst(splitIndex))
					let styledVisiblePart = word.prefix(splitIndex) // Preserve styles for the visible part

					currentLine += styledVisiblePart
					lines.append(currentLine)

					words[0] = Substring(remainingPart)
					currentLine = ""
					currentLineVisibleWidth = 0
				} else {
					lines.append(currentLine)
					currentLine = ""
					currentLineVisibleWidth = 0
				}
			}
		}

		if !currentLine.isEmpty {
			lines.append(currentLine)
		}

		return lines
	}
}

enum TextStyles: String, CaseIterable {
	case resetAll
	case bold
	case dim
	case italic
	case underline
	case blink
	case inverted
	case hidden
	case crossedOut
	case black
	case red
	case green
	case yellow
	case blue
	case magenta
	case cyan
	case white
	case defaultColor
	case brightBlack
	case brightRed
	case brightGreen
	case brightYellow
	case brightBlue
	case brightMagenta
	case brightCyan
	case brightWhite

	// case darkGray
	// case lightGray
	case orange
	case purple
	case pink
	case brown

	case highlightBlack
	case highlightRed
	case highlightGreen
	case highlightYellow
	case highlightBlue
	case highlightMagenta
	case highlightCyan
	case highlightWhite

	// Bright highlight colors
	case highlightBrightBlack
	case highlightBrightRed
	case highlightBrightGreen
	case highlightBrightYellow
	case highlightBrightBlue
	case highlightBrightMagenta
	case highlightBrightCyan
	case highlightBrightWhite

	var render: String {
		switch self {
			case .resetAll: "\u{1B}[0m"
			case .bold: "\u{1B}[1m"
			case .dim: "\u{1B}[2m"
			case .italic: "\u{1B}[3m"
			case .underline: "\u{1B}[4m"
			case .blink: "\u{1B}[5m"
			case .inverted: "\u{1B}[7m"
			case .hidden: "\u{1B}[8m"
			case .crossedOut: "\u{1B}[9m"
			case .black: "\u{1B}[30m"
			case .red: "\u{1B}[31m"
			case .green: "\u{1B}[32m"
			case .yellow: "\u{1B}[33m"
			case .blue: "\u{1B}[34m"
			case .magenta: "\u{1B}[35m"
			case .cyan: "\u{1B}[36m"
			case .white: "\u{1B}[37m"
			case .defaultColor: "\u{1B}[39m"
			case .highlightBlack: "\u{1B}[40m"
			case .highlightRed: "\u{1B}[41m"
			case .highlightGreen: "\u{1B}[42m"
			case .highlightYellow: "\u{1B}[43m"
			case .highlightBlue: "\u{1B}[44m"
			case .highlightMagenta: "\u{1B}[45m"
			case .highlightCyan: "\u{1B}[46m"
			case .highlightWhite: "\u{1B}[47m"
			case .brightBlack: "\u{1B}[90m"
			case .brightRed: "\u{1B}[91m"
			case .brightGreen: "\u{1B}[92m"
			case .brightYellow: "\u{1B}[93m"
			case .brightBlue: "\u{1B}[94m"
			case .brightMagenta: "\u{1B}[95m"
			case .brightCyan: "\u{1B}[96m"
			case .brightWhite: "\u{1B}[97m"
			case .highlightBrightBlack: "\u{1B}[100m"
			case .highlightBrightRed: "\u{1B}[101m"
			case .highlightBrightGreen: "\u{1B}[102m"
			case .highlightBrightYellow: "\u{1B}[103m"
			case .highlightBrightBlue: "\u{1B}[104m"
			case .highlightBrightMagenta: "\u{1B}[105m"
			case .highlightBrightCyan: "\u{1B}[106m"
			case .highlightBrightWhite: "\u{1B}[107m"
			case .orange: "\u{1B}[38;5;214m"
			case .purple: "\u{1B}[38;5;129m"
			case .pink: "\u{1B}[38;5;213m"
			case .brown: "\u{1B}[38;5;94m"
		}
	}
}
