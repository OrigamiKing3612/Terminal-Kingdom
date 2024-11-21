struct StartingVillageChecks: Codable {
    var hasBeenTaughtToChopLumber: StartingVillageChecksStages = .no
    var hasUsedMessageWithOptions: Bool = false
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
