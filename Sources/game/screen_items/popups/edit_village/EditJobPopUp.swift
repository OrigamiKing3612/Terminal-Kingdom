import Foundation

class EditJobPopUp: OptionsPopUpProtocol {
	var selectedOptionIndex: Int = 0
	var longestXLine: Int = 0
	var title: String
	var startY: Int = 3
	var options: [MessageOption]
	var village: Village
	var npc: NPC

	init(npc: NPC, village: Village) {
		self.title = "\(npc.name)"
		self.options = []
		self.village = village
		self.npc = npc
	}

	func before() async -> Bool {
		options = []
		var hiringBuildings: [any NPCWorkplace] = []

		for building in await village.buildings.values.compactMap({ $0 as? any NPCWorkplace }) {
			if await building.isHiring() {
				hiringBuildings.append(building)
			}
		}
		if hiringBuildings.isEmpty {
			options.append(MessageOption(label: "No buildings hiring", action: {}))
		} else {
			options.append(contentsOf: hiringBuildings.map { building in
				MessageOption(label: "\(building.type.name)", action: {
					await (Game.shared.kingdom.villages[self.village.id]?.buildings[building.id] as? any NPCWorkplace)?.hire(self.npc.id)
					await Screen.popUp(EditNPCPopUp(npc: self.npc, village: self.village))
				})
			})
		}
		options.append(MessageOption(label: "Remove Job", action: {
			await Game.shared.kingdom.removeJob(npcID: self.npc.id, villageID: self.village.id)
		}))

		return false
	}

	func input(skip: Int, lastIndex: Int, shouldExit: inout Bool) async {
		let key = TerminalInput.readKey()
		let totalOptions = options.count - 1 + 3
		switch key {
			case .up, .left, .w, .k, .h, .back_tab:
				if selectedOptionIndex > 0 {
					selectedOptionIndex -= 1
				} else {
					selectedOptionIndex = totalOptions
				}
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex - 1
				}
			case .down, .right, .s, .j, .l, .tab:
				if selectedOptionIndex < totalOptions {
					selectedOptionIndex += 1
				} else {
					selectedOptionIndex = 0
				}
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex + 1
				}
			case .enter, .space:
				if selectedOptionIndex == lastIndex + 2 {
					shouldExit = true
				} else {
					await options[selectedOptionIndex].action()
				}
			case .esc:
				shouldExit = true
			default:
				break
		}
	}
}
