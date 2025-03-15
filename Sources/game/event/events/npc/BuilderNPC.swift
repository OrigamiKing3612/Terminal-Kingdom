import Foundation

struct BuilderNPC: TalkableNPC {
	static func talk(npc: NPC) async {
		await NPC.setTalkedTo {
			await MessageBox.message("Hello, I'm \(npc.name)! I can help you with building.", speaker: .npc(name: npc.name, job: npc.job))
		}
		let options: [MessageOption] = [
			.init(label: "Quit") {},
		]
		await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options).action()
	}
}
