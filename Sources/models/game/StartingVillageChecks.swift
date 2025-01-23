struct StartingVillageChecks: Codable {
	private(set) var hasBeenTaughtToChopLumber: StartingVillageChecksStages = .no
	private(set) var hasUsedMessageWithOptions: Bool = false
	var firstTimes: FirstTimes = .init()

	mutating func setHasBeenTaughtToChopLumber(_ newHasBeenTaughtToChopLumber: StartingVillageChecksStages) {
		hasBeenTaughtToChopLumber = newHasBeenTaughtToChopLumber
	}

	mutating func setHasUsedMessageWithOptions(_ newHasUsedMessageWithOptions: Bool) {
		hasUsedMessageWithOptions = newHasUsedMessageWithOptions
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
