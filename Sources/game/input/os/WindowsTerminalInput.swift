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

			// Ensure the handle is valid
			guard hStdin != INVALID_HANDLE_VALUE else {
				return .unknown
			}

			repeat {
				ReadConsoleInputW(hStdin, &inputRecord, 1, &eventsRead)
			} while eventsRead == 0 || inputRecord.EventType != KEY_EVENT || inputRecord.Event.KeyEvent.bKeyDown == false

			let vkCode = inputRecord.Event.KeyEvent.wVirtualKeyCode
			switch vkCode {
				case 27: return .esc
				case 8: return .backspace
				case 13: return .enter
				case 32: return .space
				case 9:
					if (UInt16(GetAsyncKeyState(VK_SHIFT)) & 0x8000) != 0 {
						Logger.debug("Shift + Tab")
						return .back_tab
					}

					Logger.debug("Tab")
					return .tab
				case 0x2F: return .forward_slash
				case 0xBF: return .questionMark
				case 0x30 ... 0x39, 0x41 ... 0x5A:
					if let scalar = UnicodeScalar(vkCode) {
						Logger.debug("Pressed letter key")
						if (UInt16(GetAsyncKeyState(VK_SHIFT)) & 0x8000) != 0 {
							Logger.debug("Is pressing shift")
							return KeyboardKeys(rawValue: String(scalar).uppercased()) ?? .unknown
						} else {
							Logger.debug("not pressing shift \(UInt16(GetAsyncKeyState(VK_SHIFT)))")
							return KeyboardKeys(rawValue: String(scalar).lowercased()) ?? .unknown
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
	#endif
}
