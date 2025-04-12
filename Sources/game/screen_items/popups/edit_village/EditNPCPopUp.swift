import Foundation

class EditNPCPopUp: OptionsPopUpProtocol {
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
		options = [
			MessageOption(label: "Change Residence", action: {
				#warning("Change Residence option is not implemented yet.")
				// await Screen.popUp(ConfirmationPopUp(title: "Remove \(self.npc.name) from \(self.village.name)?", message: "Are you sure you want to remove \(self.npc.name) from the village?") {
				// 	await Game.shared.kingdom.remove(npcID: self.npc.id, villageID: self.village.id)
				// 	await Screen.popUp(EditVillagePopUp(village: self.village))
				// })
			}),
			MessageOption(label: "Remove from Village", action: {
				#warning("Remove from village option is not tested yet.")
				await Screen.popUp(ConfirmationPopUp(title: "Remove \(self.npc.name) from \(self.village.name)?", message: "Are you sure you want to remove \(self.npc.name) from the village?") {
					await Game.shared.kingdom.remove(npcID: self.npc.id, villageID: self.village.id)
					await Screen.popUp(EditVillagePopUp(village: self.village))
				})
			}),
		]
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
