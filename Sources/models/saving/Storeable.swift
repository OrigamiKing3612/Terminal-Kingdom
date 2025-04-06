import Foundation

protocol Storeable: Saveable, Loadable {}

extension Storeable {
	func save() async throws -> Data {
		var data = Data()
		let mirror = Mirror(reflecting: self)

		for case let (_, value) in mirror.children {
			guard let storeableValue = value as? Storeable else {
				throw SaveError.unknownError
			}
			try await data.append(storeableValue)
		}
		return data
	}

	init(from data: Data) throws {
		var consumedData = data
		self = try Self.createInstance(using: &consumedData)
	}

	private static func createInstance(using data: inout Data) throws -> Self {
		let instance = try Self.createEmptyInstance()
		let mirror = Mirror(reflecting: instance)

		var copiedData = data

		for case let (label?, value) in mirror.children {
			guard let type = type(of: value) as? Loadable.Type else {
				throw LoadError.invalidData
			}
			let loadedValue = try type.init(from: copiedData)
			let propertyData = try loadedValue.save()
			copiedData = copiedData.dropFirst(propertyData.count)

			try Self.setValue(instance, key: label, value: loadedValue)
		}

		data = copiedData
		return instance
	}

	private static func createEmptyInstance() throws -> Self {
		guard let empty = (Self.self as? NSObject.Type)?() as? Self else {
			throw LoadError.unknownError
		}
		return empty
	}

	private static func setValue(_ instance: Self, key: String, value: Any) throws {
		let mirror = Mirror(reflecting: instance)

		for case let (label?, child) in mirror.children {
			if label == key {
				var mutableChild = child
				mutableChild = value
			}
		}
	}
}

private enum StoreableUtils {
	static let fileVersion: UInt8 = 0x01
}

protocol Saveable {
	func save() async throws -> Data
}

extension Saveable {
	func save(to url: URL) async throws {
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
	init(from data: Data) throws
}

extension Loadable {
	static func load(from url: URL) throws -> Self {
		let data = try? Data(contentsOf: url)
		guard let data else {
			throw LoadError.fileNotFound
		}
		guard data.starts(with: [0x54, 0x4B, 0x53, StoreableUtils.fileVersion]) else {
			throw .invalidData
		}
		return try Self(from: data.dropFirst(4))
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
	mutating func append(_ data: some Saveable) async throws {
		try await append(contentsOf: data.save())
	}

	mutating func append(_ string: String) {
		if let data = string.data(using: .utf8) {
			append(data)
		}
	}
}

extension String: Saveable {
	func save() async throws -> Data {
		var data = Data()
		data.append(contentsOf: utf8)
		return data
	}
}

extension Int: Storeable {
	func save() async throws -> Data {
		withUnsafeBytes(of: littleEndian) { Data($0) }
	}

	init(from data: Data) throws {
		guard data.count >= MemoryLayout<Int>.size else {
			throw LoadError.invalidData
		}
		self = data.withUnsafeBytes { $0.load(as: Int.self) }.littleEndian
	}
}

extension Float: Storeable {
	func save() async throws -> Data {
		withUnsafeBytes(of: bitPattern.littleEndian) { Data($0) }
	}

	init(from data: Data) throws {
		guard data.count >= 4 else { throw LoadError.invalidData }
		let bitPattern = data.withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
		self = Float(bitPattern: bitPattern)
	}
}

extension Bool: Storeable {
	func save() async throws -> Data {
		Data([self ? 1 : 0])
	}

	init(from data: Data) throws {
		guard let first = data.first else { throw LoadError.invalidData }
		self = first != 0
	}
}

extension Double: Storeable {
	func save() async throws -> Data {
		var value = self
		return withUnsafeBytes(of: &value) { Data($0) }
	}

	init(from data: Data) throws {
		guard data.count == MemoryLayout<Double>.size else {
			throw LoadError.invalidData
		}
		self = data.withUnsafeBytes { $0.load(as: Double.self) }
	}
}

extension TimeInterval: Storeable {
	func save() async throws -> Data {
		let timeInterval = self
		return try await timeInterval.save()
	}

	init(from data: Data) throws {
		guard data.count >= MemoryLayout<Double>.size else {
			throw LoadError.invalidData
		}
		self = data.withUnsafeBytes { $0.load(as: Double.self) }
	}
}

extension Date: Storeable {
	func save() async throws -> Data {
		let timeInterval = timeIntervalSince1970
		return try await timeInterval.save()
	}

	init(from data: Data) throws {
		let timeInterval: Double = try Double(from: data)
		self = Date(timeIntervalSince1970: timeInterval)
	}
}

extension UUID: Storeable {
	func save() async throws -> Data {
		var data = Data()
		data.append(contentsOf: uuid)
		return data
	}

	init(from data: Data) throws {
		guard data.count >= 16 else { throw LoadError.invalidData }
		let bytes = (data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7],
		             data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15])
		self = UUID(uuid: bytes)
	}
}

extension Array: Saveable where Element: Saveable {
	func save() async throws -> Data {
		var data = Data()
		data.append(UInt8(count))
		for element in self {
			try await data.append(element)
		}
		return data
	}
}

extension Dictionary: Saveable where Key: Saveable, Value: Saveable {
	func save() async throws -> Data {
		var data = Data()
		data.append(UInt8(count))
		for (key, value) in self {
			try await data.append(key)
			try await data.append(value)
		}
		return data
	}
}
