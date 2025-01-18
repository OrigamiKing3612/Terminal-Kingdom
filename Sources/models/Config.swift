import Foundation

struct Config: Codable {
	static let configFile: String = "adventure-config.json"
	var useNerdFont: Bool = false
	var vimKeys: Bool = false
	var arrowKeys: Bool = false
	var wasdKeys: Bool = true
	private var _selectedIcon: String = ">"
	var selectedIcon: String {
		_selectedIcon.styled(with: .bold)
	}

	init() {}

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

extension Config {
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(useNerdFont, forKey: .useNerdFont)
		try container.encode(vimKeys, forKey: .vimKeys)
		try container.encode(arrowKeys, forKey: .arrowKeys)
		try container.encode(wasdKeys, forKey: .wasdKeys)
		try container.encode(_selectedIcon, forKey: .selectedIcon)
	}

	enum CodingKeys: CodingKey {
		case useNerdFont
		case vimKeys
		case arrowKeys
		case wasdKeys
		case selectedIcon
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		useNerdFont = try container.decode(Bool.self, forKey: .useNerdFont)
		vimKeys = try container.decode(Bool.self, forKey: .vimKeys)
		arrowKeys = try container.decode(Bool.self, forKey: .arrowKeys)
		wasdKeys = try container.decode(Bool.self, forKey: .wasdKeys)
		_selectedIcon = try container.decode(String.self, forKey: .selectedIcon)
	}
}
