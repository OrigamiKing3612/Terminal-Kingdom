import Foundation

protocol PopUp: AnyObject {
	var longestXLine: Int { get set }
	var title: String { get set }
	var startY: Int { get set }
	func content(yStart: inout Int) async
}

extension PopUp {
	nonisolated(unsafe) static var startX: Int { 0 }
	nonisolated(unsafe) static var middleX: Int { Screen.columns / 2 }
	nonisolated(unsafe) static var startY: Int { 0 }
	nonisolated(unsafe) static var middleY: Int { Screen.rows / 2 }
	nonisolated(unsafe) static var endY: Int { Screen.rows }

	func render() async {
		longestXLine = title.count
		var yStart = startY
		Screen.print(x: Self.middleX - (title.count / 2), y: yStart, title.styled(with: .bold))
		yStart += 3
		await content(yStart: &yStart)
	}

	func drawBorders(endY: Int, longestXLine _longestXLine: Int) async {
		let x = Self.middleX
		let longestXLine = _longestXLine + 2
		let verticalLine = await Game.shared.verticalLine
		let horizontalLine = await Game.shared.horizontalLine
		let topLeftCorner = await Game.shared.topLeftCorner
		let topRightCorner = await Game.shared.topRightCorner
		let bottomLeftCorner = await Game.shared.bottomLeftCorner
		let bottomRightCorner = await Game.shared.bottomRightCorner

		let isOdd = longestXLine % 2 != 0
		let addedLength = isOdd ? 1 : 0

		for y in startY - 3 ... endY + 1 {
			Screen.print(x: x - (longestXLine / 2) - 1, y: 1 + y, verticalLine)

			Screen.print(x: x + (longestXLine / 2) + addedLength, y: 1 + y, verticalLine)
			// Screen.print(x: box1X - 2, y: y + yStart, "\(verticalLine + String(repeating: " ", count: d) + verticalLine)")
		}
		Screen.print(x: x - (longestXLine / 2) - 1, y: startY - 3, topLeftCorner + String(repeating: horizontalLine, count: longestXLine) + topRightCorner)
		Screen.print(x: x - (longestXLine / 2) - 1, y: endY + 2, bottomLeftCorner + String(repeating: horizontalLine, count: longestXLine) + bottomRightCorner)
	}

	func print(y: Int, _ text: String) -> (yStart: Int, longestXLine: Int) {
		var longestXLine = longestXLine
		Screen.print(x: Self.middleX - (text.withoutStyles.count / 2), y: y, text)
		longestXLine = max(longestXLine, text.withoutStyles.count)
		return (y + 1, longestXLine)
	}
}
