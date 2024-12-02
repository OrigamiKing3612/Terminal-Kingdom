import Foundation

struct StaticMaps {
    static var MainMap: [[Tile]] {
        let fileManager = FileManager.default
        let currentDirectoryURL = fileManager.currentDirectoryPath
        
        let filePath = "\(currentDirectoryURL)/maps/main/main.json"
        
        do {
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            
            let data = Data(fileContents.utf8)
            return try JSONDecoder().decode([[Tile]].self, from: data)
        } catch {
            print("Could not find map file at \(filePath).")
            exit(1)
        }
    }
    static func buildingMap(for name: MapFileName) -> [[Tile]] {
        let fileManager = FileManager.default
        let currentDirectoryURL = fileManager.currentDirectoryPath
        
        let filePath = "\(currentDirectoryURL)/maps/\(name)/\(name).json"
        
        do {
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            
            let data = Data(fileContents.utf8)
            return try JSONDecoder().decode([[Tile]].self, from: data)
        } catch {
            print("Could not find map file at \(filePath).")
            exit(1)
        }
    }
    static func mapTypeToBuilding(mapType: MapType) -> MapFileName {
        switch mapType {
            case .castle: return .castle
            case .blacksmith: return .blacksmith
            case .mine: return .mine
            case .shop: return .shop
            case .builder: return .builder
            case .hunting_area: return .hunting_area
            case .inventor: return .inventor
            case .house: return .house
            case .stable: return .stable
            case .farm: return .farm
            case .hospital: return .hospital
            case .carpenter: return .carpenter
            case .restaurant: return .restaurant
            case .potter: return .potter
            case .map:
                print("Map should not be passed into buildingMap.")
                return .blacksmith
            case .mining:
                print("Mining should not be passed into buildingMap.")
                return .blacksmith
        }
    }
}

enum MapFileName: String, CaseIterable {
    case castle
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
