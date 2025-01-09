import Foundation
#if os(macOS)
	import Darwin
#elseif os(Linux)
	import Glibc
#endif

enum Placement {
	case middle
	case int(Int)
	case end
	case start
}

enum Screen {
	private(set) nonisolated(unsafe) static var columns: Int = 0
	private(set) nonisolated(unsafe) static var rows: Int = 0

	static func initialize() {
		if let terminalSize = getTerminalSize() {
			columns = terminalSize.columns
			rows = terminalSize.rows
		} else {
			Swift.print("Error: Could not determine terminal size.")
			exit(123)
		}
		MessageBox.messageBox()
		MapBox.mapBox()
		InventoryBox.inventoryBox()
		StatusBox.statusBox()
	}

	private struct TerminalSize {
		let rows: Int
		let columns: Int
	}

	enum Cursor {
		public static func move(to x: Int, _ y: Int) {
			Swift.print("\u{1B}[\(y);\(x)H", terminator: "")
		}

		public static func moveToTop() {
			Swift.print("\u{1B}[H", terminator: "")
		}
	}

	private static func getTerminalSize() -> TerminalSize? {
		var windowSize = winsize()
		#if os(Linux)
			if ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &windowSize) == 0 {
				let rows = Int(windowSize.ws_row)
				let columns = Int(windowSize.ws_col)
				return TerminalSize(rows: rows, columns: columns)
			}
		#else
			if ioctl(STDOUT_FILENO, TIOCGWINSZ, &windowSize) == 0 {
				let rows = Int(windowSize.ws_row)
				let columns = Int(windowSize.ws_col)
				return TerminalSize(rows: rows, columns: columns)
			}
		#endif
		return nil
	}

	static func clear() {
		Swift.print("\u{1B}[2J", terminator: "")
	}

	static func print(x: Int, y: Int, _ text: String) {
		Screen.print(x: .int(x), y: .int(y), text)
	}

	static func print(x: Placement, y: Placement, _ text: String) {
		let placementX = switch x {
			case .middle: (columns / 2) - (text.count / 2)
			case let .int(x): max(1, min(x, columns))
			case .end: columns - text.count
			case .start: 0
		}

		let placementY = switch y {
			case .middle: rows / 2
			case let .int(y): max(1, min(y, rows))
			case .end: rows
			case .start: 0
		}

		// Move the cursor and print text
		Cursor.move(to: placementX, placementY)
		Swift.print(text)
	}
}

extension MapBox {
	static var q1StartX: Int { Screen.columns / 2 }
	static var q1EndX: Int { Screen.columns }
	static var q1Width: Int {
		abs((Screen.columns / 2) - 3)
	}

	static var q1StartY: Int { 1 }
	static var q1EndY: Int { Screen.rows / 2 }
	static var q1Height: Int {
		abs((Screen.rows / 2) - 2)
	}
}

extension MessageBox {
	static var q2StartX: Int { 0 }
	static var q2EndX: Int { Screen.columns / 2 }
	static var q2Width: Int { q2EndX - q2StartX }

	static var q2StartY: Int { 1 }
	static var q2EndY: Int { Screen.rows / 2 }
	static var q2Height: Int { q2EndY - q2StartY }
}

extension InventoryBox {
	static var q3StartX: Int { 0 }
	static var q3EndX: Int { Screen.columns / 2 }
	static var q3Width: Int {
		abs((Screen.columns / 2) - 3)
	}

	static var q3StartY: Int { (Screen.rows / 2) + 1 }
	static var q3EndY: Int { Screen.rows - 1 }
	static var q3Height: Int {
		abs((Screen.rows / 2) - 2)
	}
}

extension StatusBox {
	static var q4StartX: Int { Screen.columns / 2 }
	static var q4EndX: Int { Screen.columns - 1 }
	static var q4Width: Int {
		abs((Screen.columns / 2) - 3)
	}

	static var q4StartY: Int { Screen.rows / 2 }
	static var q4EndY: Int { Screen.rows - 1 }
	static var q4Height: Int {
		abs((Screen.rows / 2) - 2)
	}
}
