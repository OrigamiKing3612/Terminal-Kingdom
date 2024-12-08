enum DoorTileTypes: Codable, Equatable, Hashable {
    case castle(side: CastleSide)
    case blacksmith
    case mine
    case shop
    case builder
    case hunting_area
    case inventor
    case house
    case stable
    case farm(type: FarmDoors)
    case hospital(side: HospitalSide)
    case carpenter
    case restaurant
    case potter
    
    var name: String {
        switch self {
            case .castle:
                return "Castle"
            case .blacksmith:
                return "Blacksmith"
            case .mine:
                return "Mine"
            case .shop:
                return "Shop"
            case .builder:
                return "Builder"
            case .hunting_area:
                return "Hunting Area"
            case .inventor:
                return "Inventor"
            case .house:
                return "House"
            case .stable:
                return "Stable"
            case .farm:
                return "Farm"
            case .hospital:
                return "Hospital"
            case .carpenter:
                return "Carpenter"
            case .restaurant:
                return "Restaurant"
            case .potter:
                return "Potter"
        }
    }
    var coordinatesForStartingVillageBuildings: (x: Int, y: Int) {
        //All in MainMap
        switch self {
            case .castle(let side):
                switch side {
                    case .top:
                        return (x: 66, y: 24)
                    case .right:
                        return (x: 73, y: 28)
                    case .bottom:
                        return (x: 66, y: 32)
                    case .left:
                        return (x: 59, y: 28)
                }
            case .blacksmith:
                return (x: 90, y: 35)
            case .mine:
                return (x: 39, y: 39)
            case .shop:
                return (x: 100, y: 21)
            case .builder:
                return (x: 125, y: 28)
            case .hunting_area:
                return (x: 56, y: 45)
            case .inventor:
                return (x: 96, y: 13)
            case .house:
                print("house coordinatesForStartingVillageBuildings not set")
                return (x: 1000, y: 1000)
            case .stable:
                print("stable coordinatesForStartingVillageBuildings not set")
                return (x: 1000, y: 1000)
            case .farm(let type):
                switch type {
                    case .main:
                        return (x: 52, y: 10)
                    case .farm_area:
                        return (x: 52, y: 6)
                }
            case .hospital(side: let side):
                switch side {
                    case .top:
                        return (x: 19, y: 21)
                    case .bottom:
                        return (x: 19, y: 34)
                }
            case .carpenter:
                return (x: 120, y: 41)
            case .restaurant:
                print("restaurant coordinatesForStartingVillageBuildings not set")
                return (x: 1000, y: 1000)
            case .potter:
                print("potter coordinatesForStartingVillageBuildings not set")
                return (x: 1000, y: 1000)
        }
    }
}

enum FarmDoors: Codable, Equatable, Hashable {
    case main, farm_area
}

enum HospitalSide: Codable, Equatable, Hashable {
    case top, bottom
}

enum CastleSide: Codable, Equatable, Hashable {
    case top, bottom, right, left
}
