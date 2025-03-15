import Foundation

struct BuilderNPC: TalkableNPC {
	static func talk(npc: NPC) async {
		await NPC.setTalkedTo {
			await say("Hello, I'm \(npc.name)! I can help you with building.")
		}
		await say("What would you like help with?")

		@Sendable func say(_ string: String) async {
			await MessageBox.message(string, speaker: .npc(name: npc.name, job: npc.job))
		}
	}
}
