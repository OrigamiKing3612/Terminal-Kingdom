import Foundation

protocol PopUp {
	var longestXLine: Int { get set }
	func render() async
}

extension PopUp {
	nonisolated(unsafe) static var startX: Int { 0 }
	nonisolated(unsafe) static var middleX: Int { Screen.columns / 2 }
	nonisolated(unsafe) static var startY: Int { 0 }
	nonisolated(unsafe) static var middleY: Int { Screen.rows / 2 }
	nonisolated(unsafe) static var endY: Int { Screen.rows }
}
