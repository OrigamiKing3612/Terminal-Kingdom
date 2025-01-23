enum MessageBox {
	private nonisolated(unsafe) static var messages: [String] {
		get async { await Game.shared.messages }
	}

	private nonisolated(unsafe) static var scrollOffset = 0
	private nonisolated(unsafe) static var lastMessageCount = 1
	private static var showXCounter: Bool {
		lastMessageCount > 1
	}

	static func messageBox() async {
		await sides()
		clear()
		let maxVisibleLines = height - 2
		var renderedLines: [String] = []

		for message in await messages {
			if await message == messages.last, showXCounter {
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

	static func sides() async {
		await Screen.print(x: startX + 1, y: startY, String(repeating: Game.shared.horizontalLine, count: width - 1))
		for y in (startY + 1) ..< endY {
			await Screen.print(x: startX, y: y, Game.shared.verticalLine)
			await Screen.print(x: endX, y: y, Game.shared.verticalLine)
		}
		await Screen.print(x: startX, y: endY, String(repeating: Game.shared.horizontalLine, count: width + 1))
	}

	static func clear() {
		// Redraw blank lines inside the message box
		let blankLine = String(repeating: " ", count: width - 1)
		for y in (startY + 1) ..< (endY - 1) {
			Screen.print(x: startX + 1, y: y, blankLine)
		}
	}

	static func lineUp() async {
		// Scroll up by increasing the scrollOffset
		scrollOffset += 1
		await messageBox()
	}

	static func lineDown() async {
		// Scroll down by decreasing the scrollOffset
		if scrollOffset > 0 {
			scrollOffset -= 1
			await messageBox()
		}
	}

	static func message(_ text: String, speaker: MessageSpeakers) async {
		await message(text, speaker: speaker.render)
	}

	static func message(_ text: String, speaker: NPCTileType) async {
		await message(text, speaker: speaker.render)
	}

	private static func message(_ text: String, speaker: String) async {
		// clear()
		if await text == messages.last {
			lastMessageCount += 1
		} else {
			lastMessageCount = 1
			if await speaker == MessageSpeakers.game.render {
				await Game.shared.addMessage(text)
			} else {
				await Game.shared.addMessage("\(speaker.styled(with: .bold)): \(text)")
			}
		}
		await messageBox()
	}

	@discardableResult
	static func removeLastMessage() async -> String {
		await Game.shared.messagesRemoveLast()
	}

	static func updateLastMessage(newMessage: String, speaker: MessageSpeakers) async {
		await updateLastMessage(newMessage: newMessage, speaker: speaker.render)
	}

	static func updateLastMessage(newMessage: String, speaker: NPCTileType) async {
		await updateLastMessage(newMessage: newMessage, speaker: speaker.render)
	}

	private static func updateLastMessage(newMessage: String, speaker: String) async {
		await Game.shared.messagesRemoveLast()
		await message(newMessage, speaker: speaker)
		await messageBox()
	}

	static func messageWithTyping(_ text: String, speaker: MessageSpeakers) async -> String {
		await messageWithTyping(text, speaker: speaker.render)
	}

	static func messageWithTyping(_ text: String, speaker: NPCTileType) async -> String {
		await messageWithTyping(text, speaker: speaker.render)
	}

	private static func messageWithTyping(_ text: String, speaker: String) async -> String {
		await MapBox.hideMapBox()
		StatusBox.showStatusBox = false
		let typingIcon = await Game.shared.config.selectedIcon
		await message(text, speaker: speaker)
		await message("   \(typingIcon)", speaker: .game)
		await Game.shared.setIsTypingInMessageBox(true)
		var input = "" {
			didSet {
				// Max char
				if input.count > 20 {
					input.removeLast()
				}
			}
		}
		while true {
			let key = TerminalInput.readKey()
			if key.isLetter {
				input += key.rawValue
				await updateLastMessage(newMessage: "   \(typingIcon)" + input, speaker: .game)
			} else if key == .space {
				input += " "
				await updateLastMessage(newMessage: "   \(typingIcon)" + input, speaker: .game)
			} else if key == .backspace {
				if !input.isEmpty {
					input.removeLast()
					await updateLastMessage(newMessage: "   \(typingIcon)" + input + " ", speaker: .game)
				}
			} else if key == .enter {
				if !input.isEmpty {
					break
				}
			}
		}
		await Game.shared.setIsTypingInMessageBox(false)
		await MapBox.showMapBox()
		return input.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	static func messageWithTypingNumbers(_ text: String, speaker: MessageSpeakers) async -> Int {
		await messageWithTypingNumbers(text, speaker: speaker.render)
	}

	static func messageWithTypingNumbers(_ text: String, speaker: NPCTileType) async -> Int {
		await messageWithTypingNumbers(text, speaker: speaker.render)
	}

	private static func messageWithTypingNumbers(_ text: String, speaker: String) async -> Int {
		await MapBox.hideMapBox()
		let typingIcon = await Game.shared.config.selectedIcon
		await message(text, speaker: speaker)
		await message("   \(typingIcon)", speaker: .game)
		await Game.shared.setIsTypingInMessageBox(true)
		var input = "" {
			didSet {
				// Max char
				if input.count > 20 {
					input.removeLast()
				}
			}
		}
		while true {
			let key = TerminalInput.readKey()
			if key.isNumber {
				input += key.rawValue
				await updateLastMessage(newMessage: "   \(typingIcon)" + input, speaker: .game)
			} else if key == .backspace {
				if !input.isEmpty {
					input.removeLast()
					await updateLastMessage(newMessage: "   \(typingIcon)" + input + " ", speaker: .game)
				}
			} else if key == .enter {
				if !input.isEmpty {
					break
				}
			}
		}
		await Game.shared.setIsTypingInMessageBox(false)
		await MapBox.showMapBox()
		return Int(input.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
	}

	static func messageWithOptions(_ text: String, speaker: MessageSpeakers, options: [MessageOption], hideInventoryBox: Bool = true) async -> MessageOption {
		await messageWithOptions(text, speaker: speaker.render, options: options, hideInventoryBox: hideInventoryBox)
	}

	static func messageWithOptions(_ text: String, speaker: NPCTileType, options: [MessageOption], hideInventoryBox: Bool = true) async -> MessageOption {
		await messageWithOptions(text, speaker: speaker.render, options: options, hideInventoryBox: hideInventoryBox)
	}

	private static func messageWithOptions(_ text: String, speaker: String, options: [MessageOption], hideInventoryBox: Bool) async -> MessageOption {
		guard !options.isEmpty else {
			return MessageOption(label: "Why did you this?", action: {})
		}

		await hideAllBoxes(inventoryBox: hideInventoryBox)
		await Game.shared.setIsTypingInMessageBox(true)

		let typingIcon = await Game.shared.config.selectedIcon
		var newText = text
		if await !Game.shared.startingVillageChecks.hasUsedMessageWithOptions {
			newText += " (Use your arrow keys to select an option)".styled(with: .bold)
			await Game.shared.setHasUsedMessageWithOptions(true)
		}
		await message(newText, speaker: speaker)

		var selectedOptionIndex = 0

		var messageToPrint = ""
		for (index, option) in options.enumerated() {
			let selected = (index == selectedOptionIndex) ? typingIcon : " "
			messageToPrint += "   \(selected)\(index + 1). \(option.label)"
		}
		await message(messageToPrint, speaker: .game)
		while true {
			var messageToPrint = ""
			for (index, option) in options.enumerated() {
				let selected = (index == selectedOptionIndex) ? typingIcon : " "
				messageToPrint += "   \(selected)\(index + 1). \(option.label)"
			}

			await updateLastMessage(newMessage: messageToPrint, speaker: .game)

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
					await removeLastMessage()
					await updateLastMessage(newMessage: "\(text) - \(options[selectedOptionIndex].label)", speaker: speaker)
					await showAllBoxes
					await Game.shared.setIsTypingInMessageBox(false)
					return options[selectedOptionIndex]
				default:
					break
			}
		}
	}

	static func messageWithOptionsWithLabel(_ text: String, speaker: MessageSpeakers, options: [MessageOption], hideInventoryBox: Bool = true, label: String) async -> MessageOption {
		await messageWithOptionsWithLabel(text, speaker: speaker.render, options: options, hideInventoryBox: hideInventoryBox, label: label)
	}

	static func messageWithOptionsWithLabel(_ text: String, speaker: NPCTileType, options: [MessageOption], hideInventoryBox: Bool = true, label: String) async -> MessageOption {
		await messageWithOptionsWithLabel(text, speaker: speaker.render, options: options, hideInventoryBox: hideInventoryBox, label: label)
	}

	private static func messageWithOptionsWithLabel(_ text: String, speaker: String, options: [MessageOption], hideInventoryBox: Bool, label: String) async -> MessageOption {
		guard !options.isEmpty else {
			return MessageOption(label: "Why did you this?", action: {})
		}

		await hideAllBoxes(inventoryBox: hideInventoryBox)
		await Game.shared.setIsTypingInMessageBox(true)

		let typingIcon = await Game.shared.config.selectedIcon
		var newText = text
		if await !Game.shared.startingVillageChecks.hasUsedMessageWithOptions {
			newText += " (Use your arrow keys to select an option)".styled(with: .bold)
			await Game.shared.setHasUsedMessageWithOptions(true)
		}
		await message(newText, speaker: speaker)

		var selectedOptionIndex = 0

		var messageToPrint = ""
		for (index, option) in options.enumerated() {
			let selected = (index == selectedOptionIndex) ? typingIcon : " "
			messageToPrint += "   \(selected)\(index + 1). \(option.label)"
		}
		await message(messageToPrint, speaker: .game)
		while true {
			var messageToPrint = ""
			for (index, option) in options.enumerated() {
				let selected = (index == selectedOptionIndex) ? typingIcon : " "
				messageToPrint += "   \(selected)\(index + 1). \(label) \(option.label)"
			}

			await updateLastMessage(newMessage: messageToPrint, speaker: .game)

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
					await removeLastMessage()
					await updateLastMessage(newMessage: "\(text) - \(options[selectedOptionIndex].label)", speaker: speaker)
					await showAllBoxes
					await Game.shared.setIsTypingInMessageBox(false)
					return options[selectedOptionIndex]
				default:
					break
			}
		}
	}

	static var showAllBoxes: Void {
		get async {
			await MapBox.showMapBox()
			InventoryBox.showInventoryBox = true
			StatusBox.showStatusBox = true
		}
	}

	static func hideAllBoxes(mapBox: Bool = true, inventoryBox: Bool = true, statusBox: Bool = true) async {
		if mapBox {
			await MapBox.hideMapBox()
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
	let action: () async -> Void
	let id: Int

	init(label: String, action: @escaping () async -> Void, id: Int = 1) {
		self.label = label
		self.action = action
		self.id = id
	}

	static func == (lhs: MessageOption, rhs: MessageOption) -> Bool {
		lhs.label == rhs.label
	}
}
