actor StartingVillageChecks {
	private(set) var hasBeenTaughtToChopLumber: StartingVillageChecksStages = .no
	private(set) var hasUsedMessageWithOptions: Bool = false
	private(set) var firstTimes: FirstTimes = .init()

	func setHasBeenTaughtToChopLumber(_ newHasBeenTaughtToChopLumber: StartingVillageChecksStages) {
		hasBeenTaughtToChopLumber = newHasBeenTaughtToChopLumber
	}

	func setHasUsedMessageWithOptions(_ newHasUsedMessageWithOptions: Bool) {
		hasUsedMessageWithOptions = newHasUsedMessageWithOptions
	}

	func setHasTalkedToKing() {
		firstTimes.hasTalkedToKing = true
	}

	func setHasTalkedToBlacksmith() {
		firstTimes.hasTalkedToBlacksmith = true
	}

	func setHasTalkedToMiner() {
		firstTimes.hasTalkedToMiner = true
	}

	func setHasTalkedToSalesmanBuy(_ bool: Bool = true) {
		firstTimes.hasTalkedToSalesmanBuy = bool
	}

	func setHasTalkedToSalesmanSell(_ bool: Bool = true) {
		firstTimes.hasTalkedToSalesmanSell = bool
	}

	func setHasTalkedToSalesmanHelp() {
		firstTimes.hasTalkedToSalesmanHelp = true
	}

	func setHasTalkedToBuilder() {
		firstTimes.hasTalkedToBuilder = true
	}

	func setHasTalkedToHunter() {
		firstTimes.hasTalkedToHunter = true
	}

	func setHasTalkedToInventor() {
		firstTimes.hasTalkedToInventor = true
	}

	func setHasTalkedToStableMaster() {
		firstTimes.hasTalkedToStableMaster = true
	}

	func setHasTalkedToFarmer() {
		firstTimes.hasTalkedToFarmer = true
	}

	func setHasTalkedToDoctor() {
		firstTimes.hasTalkedToDoctor = true
	}

	func setHasTalkedToChef() {
		firstTimes.hasTalkedToChef = true
	}

	func setHasTalkedToPotter() {
		firstTimes.hasTalkedToPotter = true
	}
}

struct FirstTimes: Codable {
	var hasTalkedToKing: Bool = false
	var hasTalkedToBlacksmith: Bool = false
	var hasTalkedToMiner: Bool = false
	var hasTalkedToSalesmanBuy: Bool = false
	var hasTalkedToSalesmanSell: Bool = false
	var hasTalkedToSalesmanHelp: Bool = false
	var hasTalkedToBuilder: Bool = false
	var hasTalkedToHunter: Bool = false
	var hasTalkedToInventor: Bool = false
	//    var hasTalkedToHouse: Bool = false
	var hasTalkedToStableMaster: Bool = false
	var hasTalkedToFarmer: Bool = false
	var hasTalkedToDoctor: Bool = false
	var hasTalkedToChef: Bool = false
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
