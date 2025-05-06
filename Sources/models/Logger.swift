import Foundation

class Logger {
	static let maxBackupFiles = 5
	static let logFileName = "TerminalKingdom.log"
	private nonisolated(unsafe) static let dateFormatter: ISO8601DateFormatter = .init()

	static var logFileURL: URL {
		let (_, dir, _) = Config.locations()
		return dir.appendingPathComponent(logFileName)
	}

	private init() {}

	static func initialize() {
		rotateLogs()
		createNewLogFile()
	}

	static func info(_ message: String) {
		log(message, level: .info)
	}

	static func warning(_ message: String) {
		log(message, level: .warning)
	}

	static func error(_ message: String, code: ExitCode) -> Never {
		log(message, level: .error)
		Swift.print("\(message) \(code.value)")
		exit(code.value)
	}

	static func debug(_ message: String) {
		log(message, level: .debug)
	}

	private static func log(_ message: String, level: LogLevel) {
		Task {
			guard await level <= Game.shared.config.maxLogLevel || level != .error else {
				return
			}

			let timestamp = dateFormatter.string(from: Date())
			let logMessage = "[\(level.value)] [\(timestamp)] : \(message)\n"
			let fileHandle = try FileHandle(forWritingTo: logFileURL)
			defer { fileHandle.closeFile() }

			if let data = logMessage.data(using: .utf8) {
				fileHandle.seekToEndOfFile()
				fileHandle.write(data)
			}
		}
	}

	private static func rotateLogs() {
		let fileManager = FileManager.default
		let oldestLog = logFileURL.deletingLastPathComponent().appendingPathComponent("game.log.\(maxBackupFiles)")
		if fileManager.fileExists(atPath: oldestLog.path) {
			try? fileManager.removeItem(at: oldestLog)
		}

		for i in stride(from: maxBackupFiles - 1, through: 1, by: -1) {
			let oldFile = logFileURL.deletingLastPathComponent().appendingPathComponent("game.log.\(i)")
			let newFile = logFileURL.deletingLastPathComponent().appendingPathComponent("game.log.\(i + 1)")
			if fileManager.fileExists(atPath: oldFile.path) {
				try? fileManager.moveItem(at: oldFile, to: newFile)
			}
		}

		try? fileManager.removeItem(at: logFileURL)
	}

	private static func createNewLogFile() {
		let fileManager = FileManager.default
		fileManager.createFile(atPath: logFileURL.path, contents: nil)
	}
}

enum LogLevel: Int, Codable {
	case info = 0
	case warning = 1
	case error = 2
	case debug = 3

	var value: String {
		switch self {
			case .debug: "DEBUG"
			case .info: "INFO"
			case .warning: "WARNING"
			case .error: "ERROR"
		}
	}

	static func <= (lhs: LogLevel, rhs: LogLevel) -> Bool {
		lhs.rawValue <= rhs.rawValue
	}
}

enum ExitCode {
	case couldNotDetermineTerminalSize
	case customMapNotFound
	case mainMapInMaps
	case miningMapInMaps
	case customMapInMaps
	case mainMapInBuildingMap
	case fileNotFound
	case config(ConfigErrorCode)
	case json(JsonError)
	case potteryNotImplemented
	case kingWorking

	enum JsonError {
		case decodingError
		case encodingError
	}

	enum ConfigErrorCode {
		case singleKey
		case writeError
		case missingKey
	}

	var value: Int32 {
		switch self {
			case .couldNotDetermineTerminalSize: -1
			case .customMapInMaps: 1
			case .customMapNotFound: 2
			case .mainMapInMaps: 3
			case .miningMapInMaps: 4
			case let .config(code):
				switch code {
					case .singleKey: -2
					case .writeError: -3
					case .missingKey: -4
				}
			case .fileNotFound: -5
			case let .json(code):
				switch code {
					case .decodingError: -6
					case .encodingError: -7
				}
			case .mainMapInBuildingMap: 5
			case .potteryNotImplemented: 6
			case .kingWorking: 7
		}
	}
}
