struct MessageBox {
    nonisolated(unsafe) private static var messages: [String] {
        get { Game.messages }
        set { Game.messages = newValue }
    }
    
    static let q2StartX = 0
    static let q2EndX = Screen.columns / 2
    static let q2Width = q2EndX - q2StartX
    
    static let q2StartY = 1
    static let q2EndY = Screen.rows / 2
    static let q2Height = q2EndY - q2StartY

    static func messageBox() {
        Screen.print(x: q2StartX, y: q2StartY, String(repeating: "=", count: q2Width))
        
        let maxVisibleLines = q2Height - 2
        var renderedLines: [String] = []
        
        for message in messages {
            if message.count >= q2Width - 1 {
                var currentLineStart = message.startIndex
                while currentLineStart < message.endIndex {
                    let lineEnd = message.index(currentLineStart, offsetBy: q2Width - 2, limitedBy: message.endIndex) ?? message.endIndex
                    let line = String(message[currentLineStart..<lineEnd])
                    renderedLines.append(line)
                    currentLineStart = lineEnd
                }
            } else {
                renderedLines.append(message)
            }
        }
        
        if renderedLines.count > maxVisibleLines {
            let overflow = renderedLines.count - maxVisibleLines
            renderedLines.removeFirst(overflow)
        }
        
        var currentY = q2StartY + 1
        for line in renderedLines {
            Screen.print(x: q2StartX + 2, y: currentY, line)
            currentY += 1
        }
        
        for y in currentY..<q2EndY {
            Screen.print(x: q2StartX + 1, y: y, String(repeating: " ", count: q2Width - 2))
        }
        
        for y in (q2StartY + 1)..<q2EndY {
            Screen.print(x: q2StartX, y: y, "|")
            Screen.print(x: q2EndX, y: y, "|")
        }
        
        Screen.print(x: q2StartX, y: q2EndY, String(repeating: "=", count: q2Width))
    }
    
    static func clear() {
        let blankLine = String(repeating: " ", count: q2Width - 2)
        for y in (q2StartY + 1)..<q2EndY {
            Screen.print(x: q2StartX + 1, y: y, blankLine)
        }
    }
    
    static func message(_ text: String, speaker: MessageSpeakers) {
        clear()
        if speaker == .game {
            messages.append(text)
        } else {
            messages.append("\(speaker.render.styled(with: .bold)): \(text)")
        }
        messageBox()
    }
    @discardableResult
    static func removeLastMessage() -> String {
        messages.removeLast()
    }
    static func updateLastMessage(newMessage: String, speaker: MessageSpeakers) {
        messages.removeLast()
        message(newMessage, speaker: speaker)
        messageBox()
    }
    static func messageWithTyping(_ text: String, speaker: MessageSpeakers) -> String {
        MapBox.showMapBox = false
        let typingIcon =  ">".styled(with: .bold)
        message(text, speaker: speaker)
        message("   \(typingIcon)", speaker: .game)
        Game.setIsTypingInMessageBox(true)
        var input = "" {
            didSet {
                //Max char
                if (input.count > 20) {
                    input.removeLast()
                }
                updateLastMessage(newMessage: "   \(typingIcon)" + input, speaker: speaker)
            }
        }
        while true {
            let key = TerminalInput.readKey()
            if key.isLetter {
                input += key.rawValue
            } else if key == .space {
                input += " "
            } else if key == .backspace {
                if !input.isEmpty {
                    input.removeLast()
                    updateLastMessage(newMessage: "   \(typingIcon)" + input + " ", speaker: speaker)
                }
            } else if key == .enter {
                if !input.isEmpty {
                    break
                }
            }
        }
        Game.setIsTypingInMessageBox(false)
        MapBox.showMapBox = true
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    static func messageWithOptions(_ text: String, speaker: MessageSpeakers, options: [MessageOption]) -> MessageOption {
        guard !options.isEmpty else {
            return MessageOption(label: "Why did you this?", action: {})
        }
        
        hideAllBoxes
        Game.setIsTypingInMessageBox(true)

        defer {
            showAllBoxes
            Game.setIsTypingInMessageBox(false)
        }
        
        let typingIcon = ">".styled(with: .bold)
        var newText = text
        if !Game.startingVillageChecks.hasUsedMessageWithOptions {
            newText += " (Use your arrow keys to select an option)".styled(with: .bold)
            Game.startingVillageChecks.hasUsedMessageWithOptions = true
        }
        message(newText, speaker: speaker)
        
        var selectedOptionIndex: Int = 0
        
        var messageToPrint = ""
        for (index, option) in options.enumerated() {
            let selected = (index == selectedOptionIndex) ? typingIcon : " "
            messageToPrint += "   \(selected)\(index + 1). \(option.label)"
        }
        message(messageToPrint, speaker: .game)
        while true {
            var messageToPrint = ""
            for (index, option) in options.enumerated() {
                let selected = (index == selectedOptionIndex) ? typingIcon : " "
                messageToPrint += "   \(selected)\(index + 1). \(option.label)"
            }
            
            updateLastMessage(newMessage: messageToPrint, speaker: .game)
            
            let key = TerminalInput.readKey()
            switch key {
                case .up, .left:
                    if selectedOptionIndex > 0 {
                        selectedOptionIndex -= 1
                    }
                case .down, .right:
                    if selectedOptionIndex < options.count - 1 {
                        selectedOptionIndex += 1
                    }
                case .enter:
                    removeLastMessage()
                    updateLastMessage(newMessage: "\(text) - \(options[selectedOptionIndex].label)", speaker: speaker)
                    return options[selectedOptionIndex]
                default:
                    break
            }
        }
    }
    
    static var showAllBoxes: Void {
        MapBox.showMapBox = true
        InventoryBox.showInventoryBox = true
        StatusBox.showStatusBox = true
    }
    
    static var hideAllBoxes: Void {
        MapBox.showMapBox = false
        InventoryBox.showInventoryBox = false
        StatusBox.showStatusBox = false
    }
}

struct MessageOption {
    let label: String
    let action: () -> Void
}

enum MessageSpeakers {
    case player //TODO: do I need this
    case game
    case king
    case blacksmith
    case miner
    case salesman
    case builder
    case hunter
    case inventor
    case stable_master
    case farmer
    case doctor
    case carpenter
    
    var render: String {
        switch self {
            case .player: return Game.player.name
            case .game: return "This shouldn't be seen"
            case .king: return "King"
            case .blacksmith: return "Blacksmith"
            case .miner: return "Miner"
            case .salesman: return "Salesman"
            case .builder: return "Builder"
            case .hunter: return "Hunter"
            case .inventor: return "Inventor"
            case .stable_master: return "Stable Master"
            case .farmer: return "Farmer"
            case .doctor: return "Doctor"
            case .carpenter: return "Carpenter"
        }
    }
}
