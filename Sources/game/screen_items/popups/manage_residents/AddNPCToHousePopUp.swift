import Foundation

class AddNPCToHousePopUp: OptionsPopUpProtocol {
	var longestXLine: Int = 0
	private var house: HouseBuilding
	var title: String
	var selectedOptionIndex = 0
	var options: [MessageOption]
	var startY: Int = 3
	var villageID: UUID

	init(house: HouseBuilding, villageID: UUID) async {
		self.house = house
		self.title = "Add NPC"
		self.options = []
		self.villageID = villageID
	}

	func before() async -> Bool {
		options = await Game.shared.npcs.npcs.values.filter { npc in
			npc.villageID == villageID
		}.map { npc in
			MessageOption(label: npc.name, action: {
				await Game.shared.kingdom.villages[self.villageID]?.addResident(buildingID: self.house.id, npcID: npc.id)
			})
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
