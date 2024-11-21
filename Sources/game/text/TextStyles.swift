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
            case .resetAll: return "\u{1B}[0m"
            case .bold: return "\u{1B}[1m"
            case .dim: return "\u{1B}[2m"
            case .italic: return "\u{1B}[3m"
            case .underline: return "\u{1B}[4m"
            case .blink: return "\u{1B}[5m"
            case .inverted: return "\u{1B}[7m"
            case .hidden: return "\u{1B}[8m"

            case .black: return "\u{1B}[30m"
            case .red: return "\u{1B}[31m"
            case .green: return "\u{1B}[32m"
            case .yellow: return "\u{1B}[33m"
            case .blue: return "\u{1B}[34m"
            case .magenta: return "\u{1B}[35m"
            case .cyan: return "\u{1B}[36m"
            case .white: return "\u{1B}[37m"
                
            case .brightBlack: return "\u{1B}[90m"
            case .brightRed: return "\u{1B}[91m"
            case .brightGreen: return "\u{1B}[92m"
            case .brightYellow: return "\u{1B}[93m"
            case .brightBlue: return "\u{1B}[94m"
            case .brightMagenta: return "\u{1B}[95m"
            case .brightCyan: return "\u{1B}[96m"
            case .brightWhite: return "\u{1B}[97m"
                
            case .darkGray: return "\u{1B}[90m"
            case .lightGray: return "\u{1B}[37m"
            case .orange: return "\u{1B}[38;5;214m"
            case .purple: return "\u{1B}[38;5;129m"
            case .pink: return "\u{1B}[38;5;213m"
            case .brown: return "\u{1B}[38;5;94m"
        }
    }
}
