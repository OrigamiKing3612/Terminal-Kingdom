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
                        return (x: 243, y: 119)
                    case .right:
                        return (x: 250, y: 123)
                    case .bottom:
                        return (x: 243, y: 127)
                    case .left:
                        return (x: 236, y: 123)
                }
            case .blacksmith:
                return (x: 267, y: 130)
            case .mine:
                return (x: 216, y: 124)
            case .shop:
                return (x: 277, y: 116)
            case .builder:
                return (x: 302, y: 123)
            case .hunting_area:
                return (x: 233, y: 140)
            case .inventor:
                return (x: 273, y: 108)
            case .house:
                print("house coordinatesForStartingVillageBuildings not set")
                return (x: 1000, y: 1000)
            case .stable:
                print("stable coordinatesForStartingVillageBuildings not set")
                return (x: 1000, y: 1000)
            case .farm(let type):
                switch type {
                    case .main:
                        return (x: 229, y: 105)
                    case .farm_area:
                        return (x: 231, y: 101)
                }
            case .hospital(side: let side):
                switch side {
                    case .top:
                        return (x: 196, y: 116)
                    case .bottom:
                        return (x: 196, y: 129)
                }
            case .carpenter:
                return (x: 279, y: 136)
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
