import Foundation

// MARK: - Core Protocols

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
		data.append(contentsOf: [0x54, 0x4B, 0x53, StoreableUtils.fileVersion]) // Magic number + version
		try await data.append(self)
		do {
			try data.write(to: url)
		} catch {
			throw SaveError.couldNotWriteFile(error)
		}
	}
}

protocol Loadable {
	init(from data: inout Data) throws(LoadError)
}

extension Loadable {
	static func load(from url: URL) throws(LoadError) -> Self {
		guard var data = try? Data(contentsOf: url) else {
			throw LoadError.fileNotFound
		}
		guard data.starts(with: [0x54, 0x4B, 0x53, StoreableUtils.fileVersion]) else {
			throw .invalidData
		}
		data = data.dropFirst(4) // Remove header
		return try Self(from: &data)
	}
}

// MARK: - Errors

enum SaveError: Error {
	case unknownError
	case couldNotWriteFile(Error)
}

enum LoadError: Error {
	case invalidData
	case fileNotFound
	case unknownError
}

// MARK: - Data Helpers

extension Data {
	mutating func append(_ data: some Saveable) async throws(SaveError) {
		try await append(contentsOf: data.save())
	}

	mutating func append(_ value: String) {
		let utf8Data = Data(value.utf8)
		append(UInt16(utf8Data.count).littleEndian)
		append(utf8Data)
	}

	mutating func append(_ value: some FixedWidthInteger) {
		var value = value.littleEndian
		withUnsafeBytes(of: &value) { append($0) }
	}

	mutating func append(_ value: Double) {
		var value = value.bitPattern.littleEndian
		withUnsafeBytes(of: &value) { append($0) }
	}

	mutating func append(_ value: Bool) {
		append(value ? UInt8(1) : UInt8(0))
	}
}

// MARK: - String Extension

extension String: Storeable {
	func save() async throws(SaveError) -> Data {
		var data = Data()
		try await data.append(self)
		return data
	}

	init(from data: inout Data) throws(LoadError) {
		guard data.count >= MemoryLayout<UInt16>.size else { throw LoadError.invalidData }
		let length = UInt16(littleEndian: data.withUnsafeBytes { $0.load(as: UInt16.self) })
		data = data.dropFirst(2)

		guard data.count >= length else { throw LoadError.invalidData }
		self = String(data: data.prefix(Int(length)), encoding: .utf8) ?? ""
		data = data.dropFirst(Int(length))
	}
}

// MARK: - Integer Extensions

extension Int32: Storeable {
	func save() async throws(SaveError) -> Data {
		withUnsafeBytes(of: littleEndian) { Data($0) }
	}

	init(from data: inout Data) throws(LoadError) {
		guard data.count >= MemoryLayout<Int32>.size else { throw LoadError.invalidData }
		self = data.withUnsafeBytes { $0.load(as: Int32.self) }.littleEndian
		data = data.dropFirst(MemoryLayout<Int32>.size)
	}
}

// MARK: - Double Extension

extension Double: Storeable {
	func save() async throws(SaveError) -> Data {
		withUnsafeBytes(of: bitPattern.littleEndian) { Data($0) }
	}

	init(from data: inout Data) throws(LoadError) {
		guard data.count >= MemoryLayout<UInt64>.size else { throw LoadError.invalidData }
		let bitPattern = data.withUnsafeBytes { $0.load(as: UInt64.self) }.littleEndian
		self = Double(bitPattern: bitPattern)
		data = data.dropFirst(MemoryLayout<UInt64>.size)
	}
}

// MARK: - Bool Extension

extension Bool: Storeable {
	func save() async throws(SaveError) -> Data {
		Data([self ? 1 : 0])
	}

	init(from data: inout Data) throws(LoadError) {
		guard !data.isEmpty else { throw LoadError.invalidData }
		self = data.removeFirst() == 1
	}
}

// MARK: - UUID Extension

extension UUID: Storeable {
	func save() async throws(SaveError) -> Data {
		withUnsafeBytes(of: uuid) { Data($0) }
	}

	init(from data: inout Data) throws(LoadError) {
		guard data.count >= MemoryLayout<uuid_t>.size else { throw LoadError.invalidData }
		self = data.withUnsafeBytes { UUID(uuid: $0.load(as: uuid_t.self)) }
		data = data.dropFirst(MemoryLayout<uuid_t>.size)
	}
}

// MARK: - Collection Extensions

extension Array: Saveable where Element: Saveable {
	func save() async throws(SaveError) -> Data {
		var data = Data()
		data.append(UInt32(count).littleEndian)
		for element in self {
			try await data.append(element)
		}
		return data
	}
}

extension Set: Saveable where Element: Saveable {
	func save() async throws(SaveError) -> Data {
		var data = Data()
		data.append(UInt32(count).littleEndian)
		for element in self {
			try await data.append(element)
		}
		return data
	}
}

extension Dictionary: Saveable where Key: Saveable, Value: Saveable {
	func save() async throws(SaveError) -> Data {
		var data = Data()
		data.append(UInt32(count).littleEndian)
		for (key, value) in self {
			try await data.append(key)
			try await data.append(value)
		}
		return data
	}
}
