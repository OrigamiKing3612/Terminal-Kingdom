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

struct Screen {
    nonisolated(unsafe) private(set) static var columns: Int = 0
    nonisolated(unsafe) private(set) static var rows: Int = 0

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

    struct Cursor {
        public static func move(to x: Int, _ y: Int) {
            Swift.print("\u{1B}[\(y);\(x)H", terminator: "")
        }

        public static func moveToTop() {
            Swift.print("\u{1B}[H", terminator: "")
        }
    }

    private static func getTerminalSize() -> TerminalSize? {
        var windowSize = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &windowSize) == 0 {
            let rows = Int(windowSize.ws_row)
            let columns = Int(windowSize.ws_col)
            return TerminalSize(rows: rows, columns: columns)
        }
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
                case .int(let x): max(1, min(x, columns))
                case .end: columns - text.count
                case .start: 0
            }

            let placementY = switch y {
                case .middle: rows / 2
                case .int(let y): max(1, min(y, rows))
                case .end: rows
                case .start: 0
            }

            // Move the cursor and print text
            Cursor.move(to: placementX, placementY)
            Swift.print(text)
    }
}

extension MapBox {
    static let q1StartX = (Screen.columns / 2)
    static let q1EndX = Screen.columns
    static var q1Width: Int {
        abs((Screen.columns / 2) - 3)
    }

    static let q1StartY = 1
    static let q1EndY = Screen.rows / 2
    static var q1Height: Int {
        abs((Screen.rows / 2) - 2)
    }
}

extension MessageBox {
    static let q2StartX = 0
    static let q2EndX = Screen.columns / 2
    static let q2Width = q2EndX - q2StartX

    static let q2StartY = 1
    static let q2EndY = Screen.rows / 2
    static let q2Height = q2EndY - q2StartY
}

extension InventoryBox {
    static let q3StartX = 0
    static let q3EndX = (Screen.columns / 2)
    static var q3Width: Int {
        abs((Screen.columns / 2) - 3)
    }

    static let q3StartY = (Screen.rows / 2) + 1
    static let q3EndY = Screen.rows - 1
    static var q3Height: Int {
        abs((Screen.rows / 2) - 2)
    }
}

extension StatusBox {
    static let q4StartX = (Screen.columns / 2)
    static let q4EndX = Screen.columns - 1
    static var q4Width: Int {
        abs((Screen.columns / 2) - 3)
    }

    static let q4StartY = (Screen.rows / 2)
    static let q4EndY = Screen.rows - 1
    static var q4Height: Int {
        abs((Screen.rows / 2) - 2)
    }
}
