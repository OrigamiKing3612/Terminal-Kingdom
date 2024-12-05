struct MapBox {
    nonisolated(unsafe) static var mainMap: MainMap = MainMap()
    nonisolated(unsafe) static var miningMap: MineMap = MineMap()
    nonisolated(unsafe) static var buildingMap: BuildingMap = BuildingMap(.blacksmith)
    nonisolated(unsafe) static var showMapBox = true {
        didSet {
            if showMapBox {
                mapBox()
            } else {
                clear()
            }
        }
    }
    
    nonisolated(unsafe) static var mapType: MapType = .mainMap {
        didSet {
            switch mapType {
                case .mainMap:
                    break
                case .mining:
                    miningMap = .init()
                default:
                    buildingMap = .init(mapType)
            }
            mapBox()
        }
    }
    static var player: Player {
        switch mapType {
            case .mainMap:
                mainMap.player
            case .mining:
                mainMap.player
            default:
                buildingMap.player
        }
    }
    static var tilePlayerIsOn: Tile {
        switch mapType {
            case .mainMap:
                mainMap.tilePlayerIsOn
            case .mining:
                mainMap.tilePlayerIsOn
            default:
                buildingMap.grid[buildingMap.player.y][buildingMap.player.x]
        }
    }
    
    static let q1StartX = (Screen.columns / 2)
    static let q1EndX = Screen.columns
    static var q1Width: Int {
        abs((Screen.columns / 2) - 3)
    }
    
    static let q1StartY = 1
    static let q1EndY = Screen.rows / 2
    static var q1Height: Int {
        abs((Screen.rows / 2) - 2)
    }
    
    static func mapBox() {
        clear()
        
        Screen.print(x: q1StartX, y: q1StartY, String(repeating: "=", count: q1Width + 3))
        for y in (q1StartY + 1)..<q1EndY {
            Screen.print(x: q1StartX, y: y, "|")
            Screen.print(x: q1EndX - 1, y: y, "|")
        }
        Screen.print(x: q1StartX, y: q1EndY, String(repeating: "=", count: q1Width + 3))
        
        switch mapType {
            case .mainMap:
                mainMap.map()
            case .mining:
                miningMap.map()
            default:
                buildingMap.map()
        }
    }
    
    static func clear() {
        let spaceString = String(repeating: " ", count: q1Width + 1)
        for y in (q1StartY + 1)..<q1EndY {
            Screen.print(x: q1StartX + 1, y: y, spaceString)
        }
    }
    static func movePlayer(_ direction: Direction) {
        switch mapType {
            case .mainMap:
                mainMap.movePlayer(direction)
            case .mining:
                miningMap.movePlayer(direction)
            default:
                buildingMap.movePlayer(direction)
        }
    }
    static func interactWithTile() {
        switch mapType {
            case .mainMap:
                mainMap.interactWithTile()
            case .mining:
                miningMap.interactWithTile()
            default:
                buildingMap.interactWithTile()
        }
    }
}

enum MapType: Equatable {
    case mainMap, mining
    case castle(side: CastleSide)
    case blacksmith
    case mine
    case shop
    case builder
    case hunting_area
    case inventor
    case house
    case stable
    case farm
    case hospital
    case carpenter
    case restaurant
    case potter
}

enum Direction {
    case up, down, left, right
}

struct Player: Codable {
    var x: Int
    var y: Int
}

