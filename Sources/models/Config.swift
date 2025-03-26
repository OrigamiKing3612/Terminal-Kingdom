import Foundation

// TODO: async load and save
struct Config {
	private(set) nonisolated(unsafe) static var useColors: Bool = true
	static let configFile: String = "config.json"
	var useNerdFont: Bool = false

	var vimKeys: Bool = false
	var arrowKeys: Bool = false
	var wasdKeys: Bool = true
	var icons: ConfigIcons = .init()
	var maxLogLevel: LogLevel = .info
	nonisolated(unsafe) var useHighlightsForPlainLikeTiles: Bool = false
	var useColors: Bool = true {
		didSet {
			Config.useColors = useColors
		}
	}

	init() {}

	static func locations() -> (filePath: URL, directory: URL, file: URL) {
		let filePath = FileManager.default.homeDirectoryForCurrentUser
		let directory = filePath.appendingPathComponent(".terminalkingdom")
		let file = directory.appendingPathComponent(Config.configFile)
		return (filePath, directory, file)
	}

	mutating func load() async {
		self = await Config.load()
	}

	var setUseColors: Void {
		Self.useColors = useColors
	}

	static func load() async -> Config {
		let (_, directory, file) = locations()
		do {
			if !FileManager.default.fileExists(atPath: directory.path) {
				try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
			}

			let data = try JSONDecoder().decode(Config.self, from: Data(contentsOf: file))
			return data
		} catch {
			Logger.warning("Could not read config file. Creating a new one.")
			return await write(config: Config())
		}
	}

	func write() async {
		await Config.write(config: self)
	}

	@discardableResult
	static func write(config: Config) async -> Config {
		let (_, _, file) = locations()
		do {
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			let data = try encoder.encode(config)
			try data.write(to: file)
			return config
		} catch {
			Logger.error("Could not write config file at \(file). \(error)", code: .config(.writeError))
		}
	}

	struct ConfigIcons: Codable {
		var characterIcon: String = "@"
		var buildingIcon: String = "#"
		private var _selectedIcon: String = ">"

		var selectedIcon: String {
			get { _selectedIcon.styled(with: .bold) }
			set { _selectedIcon = newValue }
		}

		init() {}

		func encode(to encoder: any Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(characterIcon, forKey: .characterIcon)
			try container.encode(buildingIcon, forKey: .buildingIcon)
			try container.encode(_selectedIcon, forKey: .selectedIcon)
		}

		enum CodingKeys: CodingKey {
			case characterIcon
			case buildingIcon
			case selectedIcon
			case maxLogLevel
		}

		init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.characterIcon = decodeIcon(container, key: .characterIcon)
			self.buildingIcon = decodeIcon(container, key: .buildingIcon)
			self._selectedIcon = decodeIcon(container, key: .selectedIcon)
		}

		private func decodeIcon(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> String {
			let icon = try? container.decode(String.self, forKey: key)
			if let icon {
				if icon.count == 1 {
					return icon
				} else {
					Logger.error("Error: icon for \(key) must be a single character.", code: .config(.singleKey))
				}
			} else {
				Logger.error("Error: icon for \(key) not found.", code: .config(.missingKey))
			}
		}
	}
}

extension Config: Codable {
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(useNerdFont, forKey: .useNerdFont)
		try container.encode(vimKeys, forKey: .vimKeys)
		try container.encode(arrowKeys, forKey: .arrowKeys)
		try container.encode(wasdKeys, forKey: .wasdKeys)
		try container.encode(icons, forKey: .icons)
		try container.encode(maxLogLevel, forKey: .maxLogLevel)
		try container.encode(useHighlightsForPlainLikeTiles, forKey: .useHighlightsForPlainLikeTiles)
		try container.encode(useColors, forKey: .useColors)
	}

	enum CodingKeys: CodingKey {
		case useNerdFont
		case vimKeys
		case arrowKeys
		case wasdKeys
		case icons
		case maxLogLevel
		case useHighlightsForPlainLikeTiles
		case useColors
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.useNerdFont = try container.decode(Bool.self, forKey: .useNerdFont)
		self.vimKeys = try container.decode(Bool.self, forKey: .vimKeys)
		self.arrowKeys = try container.decode(Bool.self, forKey: .arrowKeys)
		self.wasdKeys = try container.decode(Bool.self, forKey: .wasdKeys)
		self.icons = try container.decode(ConfigIcons.self, forKey: .icons)
		self.maxLogLevel = try container.decode(LogLevel.self, forKey: .maxLogLevel)
		self.useHighlightsForPlainLikeTiles = try container.decode(Bool.self, forKey: .useHighlightsForPlainLikeTiles)
		self.useColors = try container.decode(Bool.self, forKey: .useColors)
	}
}
