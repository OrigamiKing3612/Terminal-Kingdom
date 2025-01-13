import Foundation

enum InventoryBox {
	nonisolated(unsafe) static var showHelp: Bool = false
	nonisolated(unsafe) static var selectedInventoryIndex: Int = 0 {
		didSet {
			if selectedInventoryIndex < 0 {
				selectedInventoryIndex = 0
			} else if selectedInventoryIndex >= Game.player.items.count {
				selectedInventoryIndex = Game.player.items.count - 1
			}
			printInventory()
		}
	}

	nonisolated(unsafe) static var showInventoryBox = true {
		didSet {
			if showInventoryBox {
				inventoryBox()
			} else {
				clear()
			}
		}
	}

	static func sides() {
		Screen.print(x: q3StartX, y: q3StartY - 1, String(repeating: "=", count: q3Width + 3).styled(with: [.bold, .yellow], styledIf: Game.isInInventoryBox))
		for y in q3StartY ..< q3EndY {
			Screen.print(x: q3StartX, y: y, "|".styled(with: [.bold, .yellow], styledIf: Game.isInInventoryBox))
			Screen.print(x: q3EndX, y: y, "|".styled(with: [.bold, .yellow], styledIf: Game.isInInventoryBox))
		}
		Screen.print(x: q3StartX, y: q3EndY, String(repeating: "=", count: q3Width + 3).styled(with: [.bold, .yellow], styledIf: Game.isInInventoryBox))
	}

	static func inventoryBox() {
		clear()
		sides()
		printInventory()
	}

	static func printInventory() {
		clear()
		if showHelp {
			Screen.print(x: q3StartX + 2, y: q3StartY, "Press '\(KeyboardKeys.i.render)' to toggle inventory")
			Screen.print(x: q3StartX + 2, y: q3StartY + 1, "Press '\(KeyboardKeys.d.render)' to destroy 1")
		} else {
			var alreadyPrinted: [ItemType] = []
			for (index, item) in Game.player.items.sorted(by: { $0.type.inventoryName < $1.type.inventoryName }).enumerated() {
				if !alreadyPrinted.contains(where: { $0 == item.type }) {
					var icon = ""
					if index == selectedInventoryIndex, Game.isInInventoryBox {
						icon = "> ".styled(with: .bold)
					} else if index != selectedInventoryIndex, Game.isInInventoryBox {
						icon = "  "
					}
					Screen.print(x: q3StartX + 2, y: q3StartY + alreadyPrinted.count, "\(icon)\(item.inventoryName): \(Game.player.getCount(of: item.type))")
					alreadyPrinted.append(item.type)
				}
			}
		}
		if Game.isInInventoryBox {
			if !showHelp {
				Screen.print(x: q3StartX + 2, y: q3EndY - 1, "Press '\(KeyboardKeys.questionMark.render)' for controls")
			} else {
				Screen.print(x: q3StartX + 2, y: q3EndY - 1, "Press '\(KeyboardKeys.questionMark.render)' to leave")
			}
		} else {
			Screen.print(x: q3StartX + 2, y: q3EndY - 1, "Press '\(KeyboardKeys.i.render)'")
		}
	}

	static func destroyItem() {
		if Game.player.items.isEmpty {
			return
		}
		let uuid = Game.player.items[selectedInventoryIndex].id
		Game.player.destroyItem(id: uuid)
	}

	static func clear() {
		let spaceString = String(repeating: " ", count: q3Width + 1)
		for y in q3StartY ..< q3EndY {
			Screen.print(x: q3StartX + 2, y: y, spaceString)
		}
	}
}
