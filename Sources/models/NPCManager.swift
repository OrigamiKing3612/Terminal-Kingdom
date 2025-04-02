import Foundation

actor NPCManager {
	private(set) var npcs: [UUID: NPC] = [:]

	init() {}

	func get(npc: UUID) async -> NPC? {
		npcs[npc]
	}

	func add(npc: NPC) async {
		npcs[npc.id] = npc
	}

	func remove(npc: NPC) async {
		npcs.removeValue(forKey: npc.id)
	}

	func remove(npc: UUID) async {
		npcs.removeValue(forKey: npc)
	}

	func set(npc: NPC) async {
		npcs[npc.id] = npc
	}

	func setTalkedTo(npcID: UUID) async {
		npcs[npcID]?.updateTalkedTo()
	}
}
