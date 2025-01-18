enum MessageBox {
	private nonisolated(unsafe) static var messages: [String] {
		get { Game.messages }
		set { Game.messages = newValue }
	}

	private nonisolated(unsafe) static var scrollOffset = 0
	private nonisolated(unsafe) static var lastMessageCount = 1
	private static var showXCounter: Bool {
		lastMessageCount > 1
	}

	static func messageBox() {
		sides()
		clear()
		let maxVisibleLines = height - 2
		var renderedLines: [String] = []

		for message in messages {
			if message == messages.last, showXCounter {
				renderedLines.append(contentsOf: "\(message) (x\(lastMessageCount))".wrappedWithStyles(toWidth: width - 2))
			} else {
				renderedLines.append(contentsOf: message.wrappedWithStyles(toWidth: width - 2))
			}
		}

		scrollOffset = max(0, min(scrollOffset, max(0, renderedLines.count - maxVisibleLines)))

		// Trim to fit the visible area based on scrollOffset
		let startIndex = max(0, renderedLines.count - maxVisibleLines - scrollOffset)
		let endIndex = renderedLines.count - scrollOffset
		renderedLines = Array(renderedLines[startIndex ..< endIndex])

		var currentY = startY + 1
		for line in renderedLines {
			Screen.print(x: startX + 2, y: currentY, line)
			currentY += 1
		}

		for y in currentY ..< endY {
			Screen.print(x: startX + 1, y: y, String(repeating: " ", count: width - 2))
		}
	}

	static func sides() {
		Screen.print(x: startX + 1, y: startY, String(repeating: Game.horizontalLine, count: width - 1))
		for y in (startY + 1) ..< endY {
			Screen.print(x: startX, y: y, Game.verticalLine)
			Screen.print(x: endX, y: y, Game.verticalLine)
		}
		Screen.print(x: startX, y: endY, String(repeating: Game.horizontalLine, count: width + 1))
	}

	static func clear() {
		// Redraw blank lines inside the message box
		let blankLine = String(repeating: " ", count: width - 1)
		for y in (startY + 1) ..< (endY - 1) {
			Screen.print(x: startX + 1, y: y, blankLine)
		}
	}

	static func lineUp() {
		// Scroll up by increasing the scrollOffset
		scrollOffset += 1
		messageBox()
	}

	static func lineDown() {
		// Scroll down by decreasing the scrollOffset
		if scrollOffset > 0 {
			scrollOffset -= 1
			messageBox()
		}
	}

	static func message(_ text: String, speaker: MessageSpeakers) {
		message(text, speaker: speaker.render)
	}

	static func message(_ text: String, speaker: NPCTileType) {
		message(text, speaker: speaker.render)
	}

	private static func message(_ text: String, speaker: String) {
		// clear()
		if text == messages.last {
			lastMessageCount += 1
		} else {
			lastMessageCount = 1
			if speaker == MessageSpeakers.game.render {
				messages.append(text)
			} else {
				messages.append("\(speaker.styled(with: .bold)): \(text)")
			}
		}
		messageBox()
	}

	@discardableResult
	static func removeLastMessage() -> String {
		messages.removeLast()
	}

	static func updateLastMessage(newMessage: String, speaker: MessageSpeakers) {
		updateLastMessage(newMessage: newMessage, speaker: speaker.render)
	}

	static func updateLastMessage(newMessage: String, speaker: NPCTileType) {
		updateLastMessage(newMessage: newMessage, speaker: speaker.render)
	}

	private static func updateLastMessage(newMessage: String, speaker: String) {
		messages.removeLast()
		message(newMessage, speaker: speaker)
		messageBox()
	}

	static func messageWithTyping(_ text: String, speaker: MessageSpeakers) -> String {
		messageWithTyping(text, speaker: speaker.render)
	}

	static func messageWithTyping(_ text: String, speaker: NPCTileType) -> String {
		messageWithTyping(text, speaker: speaker.render)
	}

	private static func messageWithTyping(_ text: String, speaker: String) -> String {
		MapBox.showMapBox = false
		StatusBox.showStatusBox = false
		let typingIcon = Game.config.selectedIcon
		message(text, speaker: speaker)
		message("   \(typingIcon)", speaker: .game)
		Game.setIsTypingInMessageBox(true)
		var input = "" {
			didSet {
				// Max char
				if input.count > 20 {
					input.removeLast()
				}
				updateLastMessage(newMessage: "   \(typingIcon)" + input, speaker: .game)
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
					updateLastMessage(newMessage: "   \(typingIcon)" + input + " ", speaker: .game)
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

	static func messageWithTypingNumbers(_ text: String, speaker: MessageSpeakers) -> Int {
		messageWithTypingNumbers(text, speaker: speaker.render)
	}

	static func messageWithTypingNumbers(_ text: String, speaker: NPCTileType) -> Int {
		messageWithTypingNumbers(text, speaker: speaker.render)
	}

	private static func messageWithTypingNumbers(_ text: String, speaker: String) -> Int {
		MapBox.showMapBox = false
		let typingIcon = Game.config.selectedIcon
		message(text, speaker: speaker)
		message("   \(typingIcon)", speaker: .game)
		Game.setIsTypingInMessageBox(true)
		var input = "" {
			didSet {
				// Max char
				if input.count > 20 {
					input.removeLast()
				}

				updateLastMessage(newMessage: "   \(typingIcon)" + input, speaker: .game)
			}
		}
		while true {
			let key = TerminalInput.readKey()
			if key.isNumber {
				input += key.rawValue
			} else if key == .backspace {
				if !input.isEmpty {
					input.removeLast()
					updateLastMessage(newMessage: "   \(typingIcon)" + input + " ", speaker: .game)
				}
			} else if key == .enter {
				if !input.isEmpty {
					break
				}
			}
		}
		Game.setIsTypingInMessageBox(false)
		MapBox.showMapBox = true
		return Int(input.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
	}

	static func messageWithOptions(_ text: String, speaker: MessageSpeakers, options: [MessageOption], hideInventoryBox: Bool = true) -> MessageOption {
		messageWithOptions(text, speaker: speaker.render, options: options, hideInventoryBox: hideInventoryBox)
	}

	static func messageWithOptions(_ text: String, speaker: NPCTileType, options: [MessageOption], hideInventoryBox: Bool = true) -> MessageOption {
		messageWithOptions(text, speaker: speaker.render, options: options, hideInventoryBox: hideInventoryBox)
	}

	private static func messageWithOptions(_ text: String, speaker: String, options: [MessageOption], hideInventoryBox: Bool) -> MessageOption {
		guard !options.isEmpty else {
			return MessageOption(label: "Why did you this?", action: {})
		}

		hideAllBoxes(inventoryBox: hideInventoryBox)
		Game.setIsTypingInMessageBox(true)

		defer {
			showAllBoxes
			Game.setIsTypingInMessageBox(false)
		}

		let typingIcon = Game.config.selectedIcon
		var newText = text
		if !Game.startingVillageChecks.hasUsedMessageWithOptions {
			newText += " (Use your arrow keys to select an option)".styled(with: .bold)
			Game.startingVillageChecks.hasUsedMessageWithOptions = true
		}
		message(newText, speaker: speaker)

		var selectedOptionIndex = 0

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
				case .enter, .space:
					removeLastMessage()
					updateLastMessage(newMessage: "\(text) - \(options[selectedOptionIndex].label)", speaker: speaker)
					return options[selectedOptionIndex]
				default:
					break
			}
		}
	}

	static func messageWithOptionsWithLabel(_ text: String, speaker: MessageSpeakers, options: [MessageOption], hideInventoryBox: Bool = true, label: String) -> MessageOption {
		messageWithOptionsWithLabel(text, speaker: speaker.render, options: options, hideInventoryBox: hideInventoryBox, label: label)
	}

	static func messageWithOptionsWithLabel(_ text: String, speaker: NPCTileType, options: [MessageOption], hideInventoryBox: Bool = true, label: String) -> MessageOption {
		messageWithOptionsWithLabel(text, speaker: speaker.render, options: options, hideInventoryBox: hideInventoryBox, label: label)
	}

	private static func messageWithOptionsWithLabel(_ text: String, speaker: String, options: [MessageOption], hideInventoryBox: Bool, label: String) -> MessageOption {
		guard !options.isEmpty else {
			return MessageOption(label: "Why did you this?", action: {})
		}

		hideAllBoxes(inventoryBox: hideInventoryBox)
		Game.setIsTypingInMessageBox(true)

		defer {
			showAllBoxes
			Game.setIsTypingInMessageBox(false)
		}

		let typingIcon = Game.config.selectedIcon
		var newText = text
		if !Game.startingVillageChecks.hasUsedMessageWithOptions {
			newText += " (Use your arrow keys to select an option)".styled(with: .bold)
			Game.startingVillageChecks.hasUsedMessageWithOptions = true
		}
		message(newText, speaker: speaker)

		var selectedOptionIndex = 0

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
				messageToPrint += "   \(selected)\(index + 1). \(label) \(option.label)"
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
				case .enter, .space:
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

	static func hideAllBoxes(mapBox: Bool = true, inventoryBox: Bool = true, statusBox: Bool = true) {
		if mapBox {
			MapBox.showMapBox = false
		}
		if inventoryBox {
			InventoryBox.showInventoryBox = false
		}
		if statusBox {
			StatusBox.showStatusBox = false
		}
	}
}

struct MessageOption: Equatable {
	let label: String
	let action: () -> Void
	let id: Int

	init(label: String, action: @escaping () -> Void, id: Int = 1) {
		self.label = label
		self.action = action
		self.id = id
	}

	static func == (lhs: MessageOption, rhs: MessageOption) -> Bool {
		lhs.label == rhs.label
	}
}
