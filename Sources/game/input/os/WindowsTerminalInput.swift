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
				case 0x1B: return .esc
				case 0x08: return .backspace
				case 0x0D: return .enter
				case 0x20: return .space
				case 0x09:
					// Check if shift is held down for back-tab
					if GetAsyncKeyState(VK_SHIFT) & 0x8000 != 0 {
						return .back_tab
					}
					return .tab
				case 0x2F: return .forward_slash
				case 0xBF: return .questionMark
				case 0x30 ... 0x39, 0x41 ... 0x5A:
					if let scalar = UnicodeScalar(vkCode) {
						return KeyboardKeys(rawValue: String(scalar)) ?? .unknown
					}
				case 0x25: return .left
				case 0x27: return .right
				case 0x26: return .up
				case 0x28: return .down
				default: return .unknown
			}

			return .unknown
		}
	#endif
}
