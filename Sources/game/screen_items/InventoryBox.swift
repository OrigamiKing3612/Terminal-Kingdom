import Foundation

enum InventoryBox {
	nonisolated(unsafe) static var showHelp: Bool = false
	nonisolated(unsafe) static var showBuildHelp: Bool = false
	private(set) nonisolated(unsafe) static var selectedInventoryIndex: Int = 0 {
		didSet {
			selectedInventoryIndex = max(0, min(selectedInventoryIndex, Game.player.items.count - 1))
			printInventory()
		}
	}

	static var buildableItems: [Item] {
		Array(Set(Game.player.items.filter(\.type.isBuildable)))
			.sorted(by: sortBuildables)
	}

	private(set) nonisolated(unsafe) static var selectedBuildItemIndex: Int = 0 {
		didSet {
			selectedBuildItemIndex = max(0, min(selectedBuildItemIndex, buildableItems.count - 1))
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
		Screen.print(x: startX + 2, y: startY - 1, String(repeating: Game.horizontalLine, count: width - 2).styled(with: [.bold, .yellow], styledIf: Game.isInInventoryBox).styled(with: [.bold, .blue], styledIf: Game.isBuilding))
		for y in (startY - 1) ..< endY {
			Screen.print(x: startX, y: y, Game.verticalLine.styled(with: [.bold, .yellow], styledIf: Game.isInInventoryBox).styled(with: [.bold, .blue], styledIf: Game.isBuilding))
			Screen.print(x: endX, y: y, Game.verticalLine.styled(with: [.bold, .yellow], styledIf: Game.isInInventoryBox).styled(with: [.bold, .blue], styledIf: Game.isBuilding))
		}
		Screen.print(x: startX, y: endY, String(repeating: Game.horizontalLine, count: width).styled(with: [.bold, .yellow], styledIf: Game.isInInventoryBox).styled(with: [.bold, .blue], styledIf: Game.isBuilding))
	}

	static func inventoryBox() {
		clear()
		sides()
		printInventory()
	}

	static func printInventory() {
		clear()
		if showHelp {
			Screen.print(x: startX + 2, y: startY, "Press '\(KeyboardKeys.i.render)' to toggle inventory")
			Screen.print(x: startX + 2, y: startY + 1, "Press '\(KeyboardKeys.d.render)' to destroy 1")
		} else if showBuildHelp {
			Screen.print(x: startX + 2, y: startY, "Press '\(KeyboardKeys.b.render)' to toggle inventory")
			Screen.print(x: startX + 2, y: startY + 1, "Press '\(KeyboardKeys.enter.render)' or '\(KeyboardKeys.space.render)' to build")
			Screen.print(x: startX + 2, y: startY + 2, "Press '\(KeyboardKeys.e.render)' to destroy")
			Screen.print(x: startX + 2, y: startY + 3, "Press '\(KeyboardKeys.tab.render)' and '\(KeyboardKeys.back_tab.render)' to cycle items")
		} else if Game.isBuilding {
			var alreadyPrinted: [ItemType] = []
			for (index, item) in buildableItems.enumerated() {
				if !alreadyPrinted.contains(where: { $0 == item.type }) {
					var icon = ""
					if index == selectedBuildItemIndex, Game.isBuilding {
						icon = "> ".styled(with: .bold)
					} else if index != selectedBuildItemIndex, Game.isBuilding {
						icon = "  "
					}
					Screen.print(x: startX + 2, y: startY + alreadyPrinted.count, "\(icon)\(item.inventoryName): \(Game.player.getCount(of: item.type))")
					alreadyPrinted.append(item.type)
				}
			}
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
					Screen.print(x: startX + 2, y: startY + alreadyPrinted.count, "\(icon)\(item.inventoryName): \(Game.player.getCount(of: item.type))")
					alreadyPrinted.append(item.type)
				}
			}
		}
		if Game.isInInventoryBox || Game.isBuilding {
			if !showHelp {
				Screen.print(x: startX + 2, y: endY - 1, "Press '\(KeyboardKeys.questionMark.render)' for controls")
			} else {
				Screen.print(x: startX + 2, y: endY - 1, "Press '\(KeyboardKeys.questionMark.render)' to leave")
			}
		} else {
			Screen.print(x: startX + 2, y: endY - 1, "Press '\(KeyboardKeys.i.render)'")
		}
	}

	private static func sortBuildables(_ lhs: Item, _ rhs: Item) -> Bool {
		if lhs.type == .lumber {
			return true
		} else if rhs.type == .lumber {
			return false
		}
		return lhs.type.inventoryName < rhs.type.inventoryName
	}

	static func destroyItem() {
		if Game.player.items.isEmpty {
			return
		}
		let uuid = Game.player.items[selectedInventoryIndex].id
		Game.player.destroyItem(id: uuid)
	}

	static func clear() {
		let spaceString = String(repeating: " ", count: width - 2)
		for y in startY ..< endY {
			Screen.print(x: startX + 2, y: y, spaceString)
		}
	}

	static func nextBuildItem() {
		selectedBuildItemIndex += 1
	}

	static func previousBuildItem() {
		selectedBuildItemIndex -= 1
	}

	static func nextInventoryItem() {
		selectedInventoryIndex += 1
	}

	static func previousInventoryItem() {
		selectedInventoryIndex -= 1
	}
}
