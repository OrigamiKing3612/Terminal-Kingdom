struct StartingVillageChecks: Codable {
    var hasBeenTaughtToChopLumber: StartingVillageChecksStages = .no
    var hasUsedMessageWithOptions: Bool = false
    var firstTimes: FirstTimes = .init()
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
    var hasTalkedToCarpenter: Bool = false
    var hasTalkedToChef: Bool = false
    var hasTalkedToPotter: Bool = false
}

enum StartingVillageChecksStages: Codable, Equatable {
    case no, inProgress(by: ChoppingLumberTeachingDoorTypes), yes
}

enum ChoppingLumberTeachingDoorTypes: String, Codable, Equatable {
    case builder, miner, carpenter
    
    var name: String {
        self.rawValue.capitalized
    }
}
