extension String {
	func styled(with textStyles: [TextStyles]) -> String {
		var newString = self
		for textStyle in textStyles {
			newString = "\(textStyle.render)\(newString)"
		}
		return "\(newString)\(TextStyles.resetAll.render)"
	}

	func styled(with textStyle: TextStyles) -> String {
		styled(with: [textStyle])
	}
}

enum TextStyles {
	case bold
	case dim
	case italic
	case underline
	case blink
	case inverted
	case hidden
	case resetAll
	case black
	case red
	case green
	case yellow
	case blue
	case magenta
	case cyan
	case white
	case brightBlack
	case brightRed
	case brightGreen
	case brightYellow
	case brightBlue
	case brightMagenta
	case brightCyan
	case brightWhite

	case darkGray
	case lightGray
	case orange
	case purple
	case pink
	case brown

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
			case .black: "\u{1B}[30m"
			case .red: "\u{1B}[31m"
			case .green: "\u{1B}[32m"
			case .yellow: "\u{1B}[33m"
			case .blue: "\u{1B}[34m"
			case .magenta: "\u{1B}[35m"
			case .cyan: "\u{1B}[36m"
			case .white: "\u{1B}[37m"
			case .brightBlack: "\u{1B}[90m"
			case .brightRed: "\u{1B}[91m"
			case .brightGreen: "\u{1B}[92m"
			case .brightYellow: "\u{1B}[93m"
			case .brightBlue: "\u{1B}[94m"
			case .brightMagenta: "\u{1B}[95m"
			case .brightCyan: "\u{1B}[96m"
			case .brightWhite: "\u{1B}[97m"
			case .darkGray: "\u{1B}[90m"
			case .lightGray: "\u{1B}[37m"
			case .orange: "\u{1B}[38;5;214m"
			case .purple: "\u{1B}[38;5;129m"
			case .pink: "\u{1B}[38;5;213m"
			case .brown: "\u{1B}[38;5;94m"
		}
	}
}
