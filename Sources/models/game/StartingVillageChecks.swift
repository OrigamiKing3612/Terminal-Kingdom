actor StartingVillageChecks {
	private(set) var hasBeenTaughtToChopLumber: StartingVillageChecksStages = .no
	private(set) var hasUsedMessageWithOptions: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	private(set) var firstTimes: FirstTimes = .init()

	func setHasBeenTaughtToChopLumber(_ newHasBeenTaughtToChopLumber: StartingVillageChecksStages) {
		hasBeenTaughtToChopLumber = newHasBeenTaughtToChopLumber
	}

	func setHasUsedMessageWithOptions(_ newHasUsedMessageWithOptions: Bool) {
		hasUsedMessageWithOptions = newHasUsedMessageWithOptions
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToKing() {
		firstTimes.hasTalkedToKing = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToBlacksmith() {
		firstTimes.hasTalkedToBlacksmith = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToMiner() {
		firstTimes.hasTalkedToMiner = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToSalesmanBuy(_ bool: Bool = true) {
		firstTimes.hasTalkedToSalesmanBuy = bool
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToSalesmanSell(_ bool: Bool = true) {
		firstTimes.hasTalkedToSalesmanSell = bool
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToSalesmanHelp() {
		firstTimes.hasTalkedToSalesmanHelp = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToBuilder() {
		firstTimes.hasTalkedToBuilder = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToHunter() {
		firstTimes.hasTalkedToHunter = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToInventor() {
		firstTimes.hasTalkedToInventor = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToStableMaster() {
		firstTimes.hasTalkedToStableMaster = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToFarmer() {
		firstTimes.hasTalkedToFarmer = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToDoctor() {
		firstTimes.hasTalkedToDoctor = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToChef() {
		firstTimes.hasTalkedToChef = true
	}

	@available(*, deprecated, message: "Use NPC instead")
	func setHasTalkedToPotter() {
		firstTimes.hasTalkedToPotter = true
	}
}

struct FirstTimes: Codable {
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToKing: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToBlacksmith: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToMiner: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToSalesmanBuy: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToSalesmanSell: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToSalesmanHelp: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToBuilder: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToHunter: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToInventor: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToStableMaster: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToFarmer: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToDoctor: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToChef: Bool = false
	@available(*, deprecated, message: "Use NPC instead")
	var hasTalkedToPotter: Bool = false
}

enum StartingVillageChecksStages: Codable, Equatable {
	case no, inProgress(by: ChoppingLumberTeachingDoorTypes), yes
}

enum ChoppingLumberTeachingDoorTypes: String, Codable, Equatable {
	case builder, miner

	var name: String {
		rawValue.capitalized
	}
}
