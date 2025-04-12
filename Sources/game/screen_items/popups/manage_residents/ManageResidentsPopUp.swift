import Foundation

class ManageResidentsPopUp: OptionsPopUpProtocol {
	var longestXLine: Int = 0
	private var house: HouseBuilding
	var title: String
	var selectedOptionIndex = 0
	var options: [MessageOption]
	var startY: Int = 3
	var villageID: UUID

	init(house: HouseBuilding, villageID: UUID) async {
		self.house = house
		self.title = "Manage Residents"
		self.options = []
		self.villageID = villageID
	}

	private func removeNPC() async {
		await Screen.popUp(RemoveNPCFromHousePopUp(house: house, villageID: villageID)) {
			await MapBox.mapBox()
		}
	}

	private func addNPC() async {
		await Screen.popUp(AddNPCToHousePopUp(house: house, villageID: villageID)) {
			await MapBox.mapBox()
		}
	}

	func before() async -> Bool {
		options = []
		if await house.residents.count <= house.maxResidents {
			options.append(MessageOption(label: "Add NPC", action: addNPC))
		}
		if await house.residents.count > 0 {
			options.append(MessageOption(label: "Remove NPC", action: removeNPC))
		}
		return false
	}

	func input(skip: Int, lastIndex: Int, shouldExit: inout Bool) async {
		let key = TerminalInput.readKey()
		switch key {
			case .up, .w, .k, .back_tab:
				selectedOptionIndex = max(0, selectedOptionIndex - 1)
				if selectedOptionIndex == skip {
					selectedOptionIndex = selectedOptionIndex - 1
				}
			case .down, .s, .j, .tab:
				selectedOptionIndex = min(options.count - 1 + 3, selectedOptionIndex + 1)
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
