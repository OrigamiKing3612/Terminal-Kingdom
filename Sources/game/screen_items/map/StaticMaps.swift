import Foundation

struct StaticMaps {
    static var MainMap: [[Tile]] {
        if let fileURL = Bundle.module.url(forResource: "main", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                
                let jsonData = try JSONDecoder().decode([[Tile]].self, from: data)
                
                return jsonData
            } catch {
                print("Error loading or decoding JSON: \(error)")
                exit(1)
            }
        } else {
            print("Could not find the main map json file.")
            exit(1)
        }
    }
    static func buildingMap(for name: MapFileName) -> [[Tile]] {
        if let fileURL = Bundle.module.url(forResource: name.rawValue, withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                
                let jsonData = try JSONDecoder().decode([[Tile]].self, from: data)
                
                return jsonData
            } catch {
                print("Error loading or decoding JSON: \(error)")
                exit(1)
            }
        } else {
            print("Could not find the \(name.rawValue) map json file.")
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
