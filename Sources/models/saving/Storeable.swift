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

extension String: Saveable {
	func save() async throws(SaveError) -> Data {
		var data = Data()
		data.append(contentsOf: utf8)
		return data
	}
}

extension Int: Storeable {
	func save() async throws(SaveError) -> Data {
		var data = Data()
		var value = self
		// Store the integer as 4 bytes (Int32)
		for _ in 0 ..< 4 {
			data.append(UInt8(value & 0xFF))
			value >>= 8
		}
		return data
	}

	// TODO: test. inline ai.
	init(from data: Data) throws(LoadError) {
		guard data.count >= 4 else {
			throw LoadError.invalidData
		}
		self = Int(data[0]) | (Int(data[1]) << 8) | (Int(data[2]) << 16) | (Int(data[3]) << 24)
	}
}

extension Array: Saveable where Element: Saveable {
	func save() async throws(SaveError) -> Data {
		var data = Data()
		data.append(UInt8(count))
		for element in self {
			try await data.append(element)
		}
		return data
	}
}

extension Set: Saveable where Element: Saveable {
	func save() async throws(SaveError) -> Data {
		var data = Data()
		data.append(UInt8(count))
		for element in self {
			try await data.append(element)
		}
		return data
	}
}

extension Dictionary: Saveable where Key: Saveable, Value: Saveable {
	func save() async throws(SaveError) -> Data {
		var data = Data()
		data.append(UInt8(count))
		for (key, value) in self {
			try await data.append(key)
			try await data.append(value)
		}
		return data
	}
}
