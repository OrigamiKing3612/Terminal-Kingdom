import Foundation
import GameplayKit

actor MapGen {
	// TODO: chunks Chuck is [[Tile]]? gen new if it is nil
	// TODO: smooth from static to not static
	static let mapWidth = (500 * 2) / 2
	var mapWidth: Int { Self.mapWidth }
	static let mapHeight = 500 / 2
	var mapHeight: Int { Self.mapHeight }
	var seed: Int32
	let noiseMap: GKNoiseMap

	init() {
		self.seed = .random(in: 2 ... 1_000_000_000)
		self.noiseMap = Self.createNoiseGenerator(seed)
	}

	static func createNoiseGenerator(_ seed: Int32) -> GKNoiseMap {
		let noiseSource = GKPerlinNoiseSource(
			frequency: 0.005,
			octaveCount: 5, // Determines the detail level of the noise
			persistence: 0.4, // Controls amplitude reduction per octave
			lacunarity: 2.0, // Controls frequency increase per octave
			seed: seed // Ensure consistent generation
		)

		let noise = GKNoise(noiseSource)

		let noiseMap = GKNoiseMap(
			noise,
			size: vector_double2(Double(mapWidth), Double(mapHeight)),
			origin: vector_double2(0, 0),
			sampleCount: vector_int2(Int32(mapWidth), Int32(mapHeight)),
			seamless: true
		)

		return noiseMap
	}

	func generateFullMap() async -> [[MapTile]] {
		var map: [[MapTile]] = createMap()
		let staticRegion = StaticMaps.MainMap
		let staticWidth = staticRegion[0].count
		let staticHeight = staticRegion.count
		let startX = (mapWidth - staticWidth) / 2
		let startY = (mapHeight - staticHeight) / 2

		for y in 0 ..< staticHeight {
			for x in 0 ..< staticWidth {
				map[startY + y][startX + x] = staticRegion[y][x]
			}
		}

		for y in 0 ..< mapHeight {
			for x in 0 ..< mapWidth {
				if case let .biomeTOBEGENERATED(type) = map[y][x].type {
					switch type {
						case .desert:
							let rand = Int.random(in: 1 ... 10)
							if rand == 1 {
								map[y][x] = MapTile(type: .cactus, isWalkable: false, biome: type)
							} else {
								map[y][x] = MapTile(type: .sand, isWalkable: true, biome: type)
							}
						case .forest:
							map[y][x] = MapTile(type: .tree, isWalkable: true, event: .chopTree, biome: type)
						case .plains:
							let rand = Int.random(in: 1 ... 15)
							if rand == 2 || rand == 3 {
								map[y][x] = MapTile(type: .tree, isWalkable: true, event: .chopTree, biome: type)
							} else {
								map[y][x] = MapTile(type: .plain, isWalkable: true, biome: type)
							}
						case .snow:
							let rand = Int.random(in: 1 ... 10)
							if rand == 2 || rand == 3 {
								map[y][x] = MapTile(type: .snow_tree, isWalkable: true, biome: type)
							} else if rand == 1 {
								map[y][x] = MapTile(type: .ice, isWalkable: true, biome: type)
							} else {
								map[y][x] = MapTile(type: .snow, isWalkable: true, event: .chopTree, biome: type)
							}
						case .volcano:
							map[y][x] = MapTile(type: .TOBEGENERATED, isWalkable: true, biome: type)
						case .tuntra:
							map[y][x] = MapTile(type: .TOBEGENERATED, isWalkable: true, biome: type)
					}
				}
			}
		}

		#if DEBUG
			await outputMap(map)
			exit(0)
		#endif

		return map
	}

	#if DEBUG
		func outputMap(_ map: [[MapTile]]) async {
			do {
				let filePath = FileManager.default.homeDirectoryForCurrentUser
				let directory = filePath.appendingPathComponent(".adventure")
				let file = directory.appendingPathComponent("map.txt")
				var mapString = ""
				for (index, row) in map.enumerated() {
					for rowTile in row {
						mapString += await rowTile.type.render()
					}
					if index != map.count - 1 {
						mapString += "\n"
					}
				}
				try mapString.write(to: file, atomically: true, encoding: .utf8)
			} catch {
				print(error)
			}
		}
	#endif
	private func createMap() -> [[MapTile]] {
		var map: [[MapTile]] = []

		for y in 0 ..< mapHeight {
			var xMap: [MapTile] = []

			for x in 0 ..< mapWidth {
				let biome = getBiome(x: x, y: y)
				xMap.append(MapTile(type: .biomeTOBEGENERATED(type: biome), biome: biome))
			}

			map.append(xMap)
		}

		return map
	}

	func getBiome(x: Int, y: Int) -> BiomeType {
		let noiseValue = noiseMap.value(at: vector_int2(Int32(x), Int32(y))) * 10
		if noiseValue < -6 {
			return .volcano
		} else if noiseValue >= -6, noiseValue < -4 {
			return .desert
		} else if noiseValue >= -4, noiseValue < -3 {
			return .plains
		} else if noiseValue >= -3, noiseValue < -2 {
			return .plains
		} else if noiseValue >= -2, noiseValue < -1 {
			return .plains
		} else if noiseValue >= -1, noiseValue < 1 {
			return .forest
		} else if noiseValue >= 1, noiseValue < 2 {
			return .plains
		} else if noiseValue >= 2, noiseValue < 3 {
			return .plains
		} else if noiseValue >= 3, noiseValue < 4 {
			return .plains
		} else if noiseValue >= 4, noiseValue < 6 {
			return .snow
		} else if noiseValue >= 6 {
			return .tuntra
		} else {
			return .plains
		}
	}
}
