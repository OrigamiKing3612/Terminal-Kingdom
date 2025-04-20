import Foundation

enum NPCWork {
	static func work(npc: inout NPC) async {
		if let job = npc.job {
			switch job {
				case .blacksmith:
					await BlacksmithWork.work(npc: &npc)
				case .builder:
					await BuilderWork.work(npc: &npc)
				case .carpenter:
					await CarpenterWork.work(npc: &npc)
				case .chef:
					await ChefWork.work(npc: &npc)
				case .doctor:
					await DoctorWork.work(npc: &npc)
				case .farmer:
					await FarmerWork.work(npc: &npc)
				case .hunter:
					await HunterWork.work(npc: &npc)
				case .inventor:
					await InventorWork.work(npc: &npc)
				case .king:
					Logger.error("King should not be working", code: .kingWorking)
				case .lead_blacksmith:
					await LeadBlacksmithWork.work(npc: &npc)
				case .lead_builder:
					await LeadBuilderWork.work(npc: &npc)
				case .lead_carpenter:
					await LeadCarpenterWork.work(npc: &npc)
				case .lead_farmer:
					await LeadFarmerWork.work(npc: &npc)
				case .lead_miner:
					await LeadMinerWork.work(npc: &npc)
				case .miner:
					await MinerWork.work(npc: &npc)
				case .potter:
					await PotterWork.work(npc: &npc)
				case let .salesman(type):
					await SalesmanWork.work(npc: &npc, type: type)
				case .stable_master:
					await StableMasterWork.work(npc: &npc)
			}
		} else {
			await noJob(npc: &npc)
		}
	}

	private static func noJob(npc: inout NPC) async {
		guard case let .nojob(noJobTasks) = npc.task else {
			Logger.error("NPC has no job and no task", code: .noJobNoTask)
		}
		switch noJobTasks {
			case .idle:
				// await NPCIdle.idle(npc: &npc)
				break
			case .moveTo:
				break
		}
	}
}
