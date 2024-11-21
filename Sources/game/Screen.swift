import Foundation
import Darwin

enum Placement {
    case middle
    case int(Int)
    case end
    case start
}

struct Screen {
    nonisolated(unsafe) private(set) static var columns: Int = 0 {
        didSet {
//            initialize()
        }
    }
    nonisolated(unsafe) private(set) static var rows: Int = 0 {
        didSet {
//            initialize()
        }
    }

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
            var placementX = 0
            switch x {
                case .middle:
                    placementX = (columns / 2) - (text.count / 2)
                case .int(let x):
                    placementX = max(1, min(x, columns))
                case .end:
                    placementX = columns - text.count
                case .start:
                    placementX = 0
            }

            var placementY = 0
            switch y {
                case .middle:
                    placementY = rows / 2
                case .int(let y):
                    placementY = max(1, min(y, rows))
                case .end:
                    placementY = rows
                case .start:
                    placementY = 0
            }

            // Move the cursor and print text
            Cursor.move(to: placementX, placementY)
            Swift.print(text)
    }
}
