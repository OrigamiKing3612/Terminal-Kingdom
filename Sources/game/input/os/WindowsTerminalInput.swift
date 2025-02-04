import Foundation
#if os(Windows)
	import WinSDK
#endif

#if os(Windows)
	enum WindowsTerminalInput {
		static func readKey() -> KeyboardKeys {
			var inputRecord = INPUT_RECORD()
			var eventsRead: DWORD = 0
			let hStdin = GetStdHandle(STD_INPUT_HANDLE)

			repeat {
				ReadConsoleInputW(hStdin, &inputRecord, 1, &eventsRead)
			} while inputRecord.EventType != KEY_EVENT || inputRecord.Event.KeyEvent.bKeyDown == FALSE

			let vkCode = inputRecord.Event.KeyEvent.wVirtualKeyCode
			switch vkCode {
				case 0x1B: return .esc
				case 0x08: return .backspace
				case 0x0D: return .enter
				case 0x20: return .space
				case 0x09: return .tab
				case 0x2F: return .forward_slash
				case 0xBF: return .questionMark
				case 0x31 ... 0x39: return KeyboardKeys(rawValue: String(UnicodeScalar(vkCode))) ?? .unknown
				case 0x41 ... 0x5A, 0x61 ... 0x7A: return KeyboardKeys(rawValue: String(UnicodeScalar(vkCode))) ?? .unknown
				case VK_LEFT: return .left
				case VK_RIGHT: return .right
				case VK_UP: return .up
				case VK_DOWN: return .down
				case VK_TAB where GetKeyState(VK_SHIFT) & 0x8000 != 0: return .back_tab
				case VK_F1: return .f1
				case VK_F2: return .f2
				case VK_F3: return .f3
				case VK_F4: return .f4
				case VK_F5: return .f5
				case VK_F6: return .f6
				case VK_F7: return .f7
				case VK_F8: return .f8
				case VK_F9: return .f9
				case VK_F10: return .f10
				case VK_F11: return .f11
				case VK_F12: return .f12
				default: return .unknown
			}
		}
	}
#endif
