import Foundation

class RemoveNPCFromHousePopUp: OptionsPopUpProtocol {
	var longestXLine: Int = 0
	private var house: HouseBuilding
	var title: String
	var selectedOptionIndex = 0
	var options: [MessageOption]
	var startY: Int = 3
	var villageID: UUID

	init(house: HouseBuilding, villageID: UUID) async {
		self.house = house
		self.title = "Remove NPC"
		self.options = []
		self.villageID = villageID
	}

	func before() async -> Bool {
		options = []
		for npcID in await house.residents {
			if let npc = await Game.shared.npcs.npcs[npcID] {
				options.append(MessageOption(label: npc.name, action: { [villageID] in
					await Game.shared.kingdom.villages[villageID]?.removeResident(buildingID: self.house.id, npcID: npcID)
				}))
			}
		}
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
