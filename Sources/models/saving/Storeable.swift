import Foundation

protocol Storeable: Saveable, Loadable {}
private enum StoreableUtils {
	static let fileVersion: UInt8 = 0x01
}

protocol Saveable {
	func save() async throws(SaveError) -> Data
}

extension Saveable {
	func save(to url: URL) async throws(SaveError) {
		var data = Data()
		data.append(contentsOf: [0x54, 0x4B, 0x53, StoreableUtils.fileVersion])
		try await data.append(self)
		do {
			try data.write(to: url)
		} catch {
			throw SaveError.couldNotWriteFile
		}
	}
}

protocol Loadable {
	init(from data: Data) throws(LoadError)
}

extension Loadable {
	static func load(from url: URL) throws(LoadError) -> Self {
		let data = try? Data(contentsOf: url)
		guard let data else {
			throw LoadError.fileNotFound
		}
		guard data.starts(with: [0x54, 0x4B, 0x53, StoreableUtils.fileVersion]) else {
			throw .invalidData
		}
		return try Self(from: data.dropFirst(4)) // Remove the header before parsing
	}
}

enum SaveError: Error {
	case unknownError
	case couldNotWriteFile
}

enum LoadError: Error {
	case invalidData
	case fileNotFound
	case unknownError
}

extension Data {
	mutating func append(_ data: some Saveable) async throws(SaveError) {
		try await append(contentsOf: data.save())
	}

	mutating func append(_ string: String) {
		if let data = string.data(using: .utf8) {
			append(data)
		}
	}
}
