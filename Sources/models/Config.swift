import Foundation

struct Config: Codable {
	static let configFile: String = "adventure-config.json"
	var useNerdFont: Bool = true
	var vimKeys: Bool = false
	var arrowKeys: Bool = false
	var wasdKeys: Bool = true

	static func locations() -> (filePath: URL, directory: URL, file: URL) {
		let filePath = FileManager.default.homeDirectoryForCurrentUser
		let directory = filePath.appendingPathComponent(".adventure")
		let file = directory.appendingPathComponent(Config.configFile)
		return (filePath, directory, file)
	}

	static func load() -> Config {
		let (_, directory, file) = locations()
		do {
			if !FileManager.default.fileExists(atPath: directory.path) {
				try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
			}

			let data = try JSONDecoder().decode(Config.self, from: Data(contentsOf: file))
			return data
		} catch {
			print("Error: Could not read config file. Creating a new one.")
			return write(config: Config())
		}
	}

	func write() {
		Config.write(config: self)
	}

	@discardableResult
	static func write(config: Config) -> Config {
		let (_, _, file) = locations()
		do {
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			let data = try encoder.encode(config)
			try data.write(to: file)
			return config
		} catch {
			print("Error: Could not write config file at \(file). \(error)")
			exit(1)
		}
	}
}
