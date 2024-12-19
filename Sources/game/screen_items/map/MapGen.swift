import Noise
import Foundation

struct MapGenSave: Codable {
    static let defaultAmplitude: Double = 1.0
    static let defaultFrequency: Double = 0.005
    
    var amplitude: Double
    var frequency: Double
    var seed: Int
    
    init(amplitude: Double, frequency: Double, seed: Int) {
        self.amplitude = amplitude
        self.frequency = frequency
        self.seed = seed
    }
}

struct MapGen {
    //TODO: chunks Chuck is [[Tile]]? gen new if it is nil
    //TODO: smooth from static to not static
    static let mapWidth = (500 * 2) / 2
    static let mapHeight = (500) / 2
    
    static func generateFullMap() -> [[MapTile]] {
        //amplitude = common parts more common, frequency is size of biome.
        let noise = GradientNoise2D(amplitude: Game.mapGen.amplitude, frequency: Game.mapGen.frequency, seed: Game.mapGen.seed)
        
        var map: [[MapTile]] = Array(repeating: Array(repeating: MapTile(type: .TOBEGENERATED), count: mapWidth), count: mapHeight)
        
        let staticRegion = StaticMaps.MainMap
        let staticWidth = staticRegion[0].count
        let staticHeight = staticRegion.count
        
        let startX = (mapWidth - staticWidth) / 2
        let startY = (mapHeight - staticHeight) / 2
        
        for y in 0..<staticHeight {
            for x in 0..<staticWidth {
                map[startY + y][startX + x] = staticRegion[y][x]
            }
        }
        
        for y in 0..<mapHeight {
            for x in 0..<mapWidth {
                if map[y][x] == MapTile(type: .TOBEGENERATED) {
                    let noiseValue = noise.evaluate(Double(x), Double(y)) * 10 // -10, 10
                    
                    if noiseValue < -3 {
                        let rand = Int.random(in: 1...10)
                        if rand == 2 || rand == 3 {
                            map[y][x] = MapTile(type: .snow_tree, isWalkable: true)
                        } else if rand == 1 {
                            map[y][x] = MapTile(type: .ice, isWalkable: true)
                        } else {
                            map[y][x] = MapTile(type: .snow, isWalkable: true, event: .chopTree)
                        }
                    } else if noiseValue < -5 {
                        let rand = Int.random(in: 1...10)
                        if rand == 1 {
                            map[y][x] = MapTile(type: .cactus, isWalkable: false)
                        } else {
                            map[y][x] = MapTile(type: .sand, isWalkable: true)
                        }
                    } else if noiseValue < 3 {
                        let rand = Int.random(in: 1...15)
                        if rand == 2 || rand == 3 {
                            map[y][x] = MapTile(type: .tree, isWalkable: true, event: .chopTree)
                        } else {
                            map[y][x] = MapTile(type: .plain, isWalkable: true)
                        }
                    } else {
                        map[y][x] = MapTile(type: .tree, isWalkable: true, event: .chopTree)
                    }
                }
            }
        }
        
        return map
    }
}

