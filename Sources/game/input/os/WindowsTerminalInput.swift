import Foundation
#if os(Windows)
	import WinSDK
#endif

enum WindowsTerminalInput {
	#if os(Windows)
		static func readKey() -> KeyboardKeys {
			var inputRecord = INPUT_RECORD()
			var eventsRead: DWORD = 0
			let hStdin = GetStdHandle(STD_INPUT_HANDLE)

			guard hStdin != INVALID_HANDLE_VALUE else {
				return .unknown
			}

			repeat {
				ReadConsoleInputW(hStdin, &inputRecord, 1, &eventsRead)
			} while eventsRead == 0 || inputRecord.EventType != KEY_EVENT || inputRecord.Event.KeyEvent.bKeyDown == false

			let vkCode = inputRecord.Event.KeyEvent.wVirtualKeyCode
			let keyEvent = inputRecord.Event.KeyEvent
			let controlState = keyEvent.dwControlKeyState
			let isShiftHeld = (controlState & DWORD(SHIFT_PRESSED)) != 0

			if isShiftHeld {
				Logger.debug("Is pressing shift")
			} else {
				Logger.debug("Not pressing shift")
			}

			switch vkCode {
				case 0x1B: return .esc
				case 0x08: return .backspace
				case 0x0D: return .enter
				case 0x20: return .space
				case 0x09:
					if isShiftHeld {
						return .back_tab
					}

					Logger.debug("Tab")
					return .tab
				case 0x2F: return .forward_slash
				case 0xBF: return .questionMark
				case 0x30 ... 0x39, 0x41 ... 0x5A:
					if let scalar = mapVirtualKeyToCharacter(vkCode: vkCode) {
						Logger.debug("Pressed letter key")
						if isShiftHeld {
							return KeyboardKeys(rawValue: scalar) ?? .unknown
						} else {
							return KeyboardKeys(rawValue: scalar.lowercased()) ?? .unknown
						}
					}
				case 0x25: return .left
				case 0x27: return .right
				case 0x26: return .up
				case 0x28: return .down
				default: return .unknown
			}

			Logger.warning("Unknown key: \(vkCode)")
			return .unknown
		}

		private static func mapVirtualKeyToCharacter(vkCode: UInt16) -> String? {
			switch vkCode {
				case 0x30: "0"
				case 0x31: "1"
				case 0x32: "2"
				case 0x33: "3"
				case 0x34: "4"
				case 0x35: "5"
				case 0x36: "6"
				case 0x37: "7"
				case 0x38: "8"
				case 0x39: "9"
				case 0x41: "A"
				case 0x42: "B"
				case 0x43: "C"
				case 0x44: "D"
				case 0x45: "E"
				case 0x46: "F"
				case 0x47: "G"
				case 0x48: "H"
				case 0x49: "I"
				case 0x4A: "J"
				case 0x4B: "K"
				case 0x4C: "L"
				case 0x4D: "M"
				case 0x4E: "N"
				case 0x4F: "O"
				case 0x50: "P"
				case 0x51: "Q"
				case 0x52: "R"
				case 0x53: "S"
				case 0x54: "T"
				case 0x55: "U"
				case 0x56: "V"
				case 0x57: "W"
				case 0x58: "X"
				case 0x59: "Y"
				case 0x5A: "Z"
				default: nil
			}
		}
	#endif
}
