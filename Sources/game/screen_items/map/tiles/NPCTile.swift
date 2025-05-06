import Foundation

struct NPCTile: Codable, Hashable, Equatable {
	static let startingVillageID = UUID()
	let id: UUID
	let npcID: UUID
	var npc: NPC {
		get async {
			let npc = await Game.shared.npcs[npcID]
			assert(npc != nil, "NPC not found for NPCTile with ID: \(id) and npcID: \(npcID)")
			return npc!
		}
	}

	init(id: UUID = UUID(), npcID: UUID) {
		self.id = id
		self.npcID = npcID
	}

	init(id: UUID = UUID(), npc: NPC) {
		self.id = id
		self.npcID = npc.id
		Task {
			await Game.shared.npcs.add(npc: npc)
		}
	}

	static func renderNPC(tile: NPCTile) async -> String {
		let npc = await tile.npc
		if !npc.hasTalkedToBefore {
			if let job = npc.job, !job.isNotLead {
				return "!".styled(with: [.bold, .red])
			}
		}
		switch npc.job {
			default:
				if npc.positionToWalkTo != nil {
					return await (Game.shared.config.useNerdFont ? "" : "N").styled(with: .bold)
				} else {
					let nerdFontSymbol = npc.gender == .male ? "󰙍" : "󰙉"
					return await (Game.shared.config.useNerdFont ? nerdFontSymbol : "N").styled(with: .bold)
				}
		}
	}
}

extension NPCTile {
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(npcID, forKey: .npcID)
	}

	enum CodingKeys: CodingKey {
		case id
		case npcID
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.npcID = try container.decode(UUID.self, forKey: .npcID)
	}
}
