import Foundation

actor NPCManager {
	private(set) var npcs: [UUID: NPC] = [:]

	init() {}

	func get(npc: UUID) async -> NPC? {
		npcs[npc]
	}

	func add(npc: NPC) async {
		if npcs.isEmpty {
			BackgroundTasks.startNPCQueue()
		}
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

	func removeNPCPosition(npcID: UUID) async {
		npcs[npcID]?.removePosition()
	}

	func getNPC(for position: NPCPosition) -> NPC? {
		npcs.values.first { $0.position == position }
	}

	func addHappiness(npcID: UUID, amount: Double) async {
		npcs[npcID]?.addHappiness(amount)
	}

	func removeHappiness(npcID: UUID, amount: Double) async {
		npcs[npcID]?.removeHappiness(amount)
	}

	func removeJob(npcID: UUID) async {
		npcs[npcID]?.job = nil
	}

	subscript(id: UUID) -> NPC? {
		npcs[id]
	}
}
