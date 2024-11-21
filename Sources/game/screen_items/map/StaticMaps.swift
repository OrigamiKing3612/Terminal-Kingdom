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
}
