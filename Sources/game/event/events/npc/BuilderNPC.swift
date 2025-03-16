import Foundation

struct BuilderNPC: TalkableNPC {
	static func talk(npc: NPC) async {
		await NPC.setTalkedTo {
			#warning("Test this")
			let kingdom = await Game.shared.kingdoms.first { $0.npcsInKindom.contains(npc.id) }
			if let kingdom {
				if kingdom.hasCastle {
					await MessageBox.message("Hello, I'm \(npc.name)! I can help you with building. Let's start! Go get all of the materials you need and then we can build your castle!", speaker: .npc(name: npc.name, job: npc.job))
					await Game.shared.player.setCanBuild(false)
				} else {
					if kingdom.data.contains(.buildingCastle) {
						await MessageBox.message("You are back! Would you like to continue working on your castle?", speaker: .npc(name: npc.name, job: npc.job))
						let options: [MessageOption] = [
							.init(label: "Quit", action: {}),
							.init(label: "I'm not done", action: {}),
							.init(label: "I'm done!", action: {}),
						]
						let option = await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options)
						if option.label == options[2].label {
							if await Game.shared.player.has(item: .door(tile: .init(type: .castle(side: .top)))) {
								await MessageBox.message("Great! Your castle is now complete!", speaker: .npc(name: npc.name, job: npc.job))
								await Game.shared.removeKingdomData(.buildingCastle, npcInKindom: npc.id)
							} else {
								await MessageBox.message("You haven't placed your castle door yet.", speaker: .npc(name: npc.name, job: npc.job))
							}
						}
					} else {
						await MessageBox.message("You are back! Would you like to start working on your castle?", speaker: .npc(name: npc.name, job: npc.job))
						let options: [MessageOption] = [
							.init(label: "Quit", action: {}),
							.init(label: "Build your Castle", action: {}),
						]
						let option = await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options)
						if option.label == options[1].label {
							await Game.shared.player.setCanBuild(true)
							//! TODO: remove the castle(.top) from this
							_ = await Game.shared.player.collect(item: .init(type: .door(tile: .init(type: .castle(side: .top))), canBeSold: false))
							await MessageBox.message("Let me know when you are done!", speaker: .npc(name: npc.name, job: npc.job))
							await Game.shared.addKingdomData(.buildingCastle, npcInKindom: npc.id)
						} else {
							await MessageBox.message("Ok, let me know when you are ready to start building!", speaker: .npc(name: npc.name, job: npc.job))
						}
					}
				}
			} else {
				await MessageBox.message("I don't know what to do", speaker: .npc(name: npc.name, job: npc.job))
			}
		}
		let options: [MessageOption] = [
			.init(label: "Quit") {},
		]
		await MessageBox.messageWithOptions("What can I do for you?", speaker: .npc(name: npc.name, job: npc.job), options: options).action()
	}
}
