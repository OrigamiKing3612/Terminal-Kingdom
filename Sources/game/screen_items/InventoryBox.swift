import Foundation

enum InventoryBox {
	private(set) nonisolated(unsafe) static var updateInventoryBox = false
	nonisolated(unsafe) static var showHelp: Bool = false
	nonisolated(unsafe) static var showBuildHelp: Bool = false
	private(set) nonisolated(unsafe) static var selectedInventoryIndex: Int = 0 {
		didSet {
			Task {
				selectedInventoryIndex = await max(0, min(selectedInventoryIndex, inventoryItems.count - 1))
				await printInventory()
			}
		}
	}

	static var inventoryItems: [Item] {
		get async {
			await Game.shared.player.items
				.reduce(into: [Item]()) { result, item in
					// Deduplicate based on `type` or any relevant property
					if !result.contains(where: { $0.type == item.type }) {
						result.append(item)
					}
				}
				.sorted(by: { $0.type.inventoryName < $1.type.inventoryName })
		}
	}

	static var buildableItems: [Item] {
		get async {
			await Game.shared.player.items
				.filter(\.type.isBuildable)
				.reduce(into: [Item]()) { result, item in
					// Deduplicate based on `type` or any relevant property
					if !result.contains(where: { $0.type == item.type }) {
						result.append(item)
					}
				}
				.sorted(by: sortBuildables)
		}
	}

	private(set) nonisolated(unsafe) static var selectedBuildItemIndex: Int = 0 {
		didSet {
			Task {
				selectedBuildItemIndex = await max(0, min(selectedBuildItemIndex, buildableItems.count - 1))
				await printInventory()
			}
		}
	}

	nonisolated(unsafe) static var showInventoryBox = true {
		didSet {
			if showInventoryBox {
				Task {
					await inventoryBox()
				}
			} else {
				clear()
			}
		}
	}

	static var resetSelectedBuildItemIndex: Void {
		selectedBuildItemIndex = 0
	}

	static func sides() async {
		await Screen.print(x: startX + 2, y: startY - 1, String(repeating: Game.shared.horizontalLine, count: width - 2).styled(with: [.bold, .yellow], styledIf: Game.shared.isInInventoryBox).styled(with: [.bold, .blue], styledIf: Game.shared.isBuilding))
		for y in (startY - 1) ..< endY {
			await Screen.print(x: startX, y: y, Game.shared.verticalLine.styled(with: [.bold, .yellow], styledIf: Game.shared.isInInventoryBox).styled(with: [.bold, .blue], styledIf: Game.shared.isBuilding))
			await Screen.print(x: endX, y: y, Game.shared.verticalLine.styled(with: [.bold, .yellow], styledIf: Game.shared.isInInventoryBox).styled(with: [.bold, .blue], styledIf: Game.shared.isBuilding))
		}
		await Screen.print(x: startX, y: endY, String(repeating: Game.shared.horizontalLine, count: width).styled(with: [.bold, .yellow], styledIf: Game.shared.isInInventoryBox).styled(with: [.bold, .blue], styledIf: Game.shared.isBuilding))
	}

	static func inventoryBox() async {
		if await !Game.shared.isBuilding {
			updateInventoryBox = false
		}
		clear()
		await sides()
		await printInventory()
	}

	static func printInventory() async {
		clear()
		if showHelp {
			Screen.print(x: startX + 2, y: startY, "Press '\(KeyboardKeys.i.render)' to toggle inventory")
			Screen.print(x: startX + 2, y: startY + 1, "Press '\(KeyboardKeys.d.render)' to destroy 1")
		} else if showBuildHelp {
			Screen.print(x: startX + 2, y: startY, "Press '\(KeyboardKeys.b.render)' to toggle inventory")
			Screen.print(x: startX + 2, y: startY + 1, "Press '\(KeyboardKeys.enter.render)' or '\(KeyboardKeys.space.render)' to build")
			Screen.print(x: startX + 2, y: startY + 2, "Press '\(KeyboardKeys.e.render)' to destroy")
			Screen.print(x: startX + 2, y: startY + 3, "Press '\(KeyboardKeys.tab.render)' and '\(KeyboardKeys.back_tab.render)' to cycle items")
		} else if await Game.shared.isBuilding {
			var alreadyPrinted: [ItemType] = []
			let buildableItems = await buildableItems.enumerated()
			for (index, item) in buildableItems {
				if !alreadyPrinted.contains(where: { $0 == item.type }) {
					var icon = ""
					if index == selectedBuildItemIndex, await Game.shared.isBuilding {
						icon = "> ".styled(with: .bold)
					} else if index != selectedBuildItemIndex, await Game.shared.isBuilding {
						// icon = "  "
						icon = " "
					}
					await Screen.print(x: startX + 2, y: startY + alreadyPrinted.count, "\(icon)\(item.inventoryName): \(Game.shared.player.getCount(of: item.type))")
					alreadyPrinted.append(item.type)
				}
			}
		} else {
			var alreadyPrinted: [ItemType] = []
			let inventoryItems = await inventoryItems.enumerated()
			for (index, item) in inventoryItems {
				if !alreadyPrinted.contains(where: { $0 == item.type }) {
					var icon = ""
					if index == selectedInventoryIndex, await Game.shared.isInInventoryBox {
						icon = "> ".styled(with: .bold)
					} else if index != selectedInventoryIndex, await Game.shared.isInInventoryBox {
						icon = "  "
					}
					await Screen.print(x: startX + 3, y: startY + alreadyPrinted.count, "\(icon)\(item.inventoryName): \(Game.shared.player.getCount(of: item.type))")
					alreadyPrinted.append(item.type)
				}
			}
		}
		let isInInventoryBox = await Game.shared.isInInventoryBox
		let isBuilding = await Game.shared.isBuilding

		if isInInventoryBox || isBuilding {
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

	static func destroyItem() async {
		if await inventoryItems.isEmpty {
			return
		}
		let uuid = await inventoryItems[selectedInventoryIndex].id
		await Game.shared.player.destroyItem(id: uuid)
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

	static func setUpdateInventoryBox() {
		updateInventoryBox = true
	}
}
