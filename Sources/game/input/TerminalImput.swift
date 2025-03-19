import Foundation
#if os(macOS)
	import Darwin
#elseif os(Linux)
	import Glibc
#elseif os(Windows)
	import WinSDK
#endif

enum TerminalInput {
	#if !os(Windows)
		private nonisolated(unsafe) static var originalTermios = termios()
	#endif

	static func enableRawMode() {
		#if os(Windows)
			var mode: DWORD = 0
			let hStdin = GetStdHandle(STD_INPUT_HANDLE)
			GetConsoleMode(hStdin, &mode)
			SetConsoleMode(hStdin, mode & ~DWORD(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT))
		#else
			var raw = termios()
			tcgetattr(STDIN_FILENO, &originalTermios)
			raw = originalTermios
			#if os(Linux)
				raw.c_lflag &= ~UInt32(ECHO | ICANON)
			#else
				raw.c_lflag &= ~UInt(ECHO | ICANON)
			#endif
			tcsetattr(STDIN_FILENO, TCSANOW, &raw)
		#endif
	}

	static func restoreOriginalMode() {
		#if os(Windows)
			let handle = GetStdHandle(STD_INPUT_HANDLE)
			var mode: DWORD = 0
			GetConsoleMode(handle, &mode)
			mode &= ~DWORD(ENABLE_PROCESSED_INPUT)
			SetConsoleMode(handle, mode)
		#else
			tcsetattr(STDIN_FILENO, TCSANOW, &originalTermios)
		#endif
	}

	static func readKey() -> KeyboardKeys {
		#if os(Windows)
			WindowsTerminalInput.readKey()
		#else
			UnixTerminalInput.readKey()
		#endif
	}
}
