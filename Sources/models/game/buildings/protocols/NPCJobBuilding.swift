import Foundation

protocol NPCJobBuilding: Equatable, Hashable, Identifiable, Sendable {
	var workers: Set<UUID> { get }

	func addWorker(_ worker: UUID) async
	func removeWorker(_ worker: UUID) async
}
