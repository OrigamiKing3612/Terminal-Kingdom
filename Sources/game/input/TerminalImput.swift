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

	// Enable raw mode
	static func enableRawMode() {
		#if os(Windows)
			var mode: DWORD = 0
			let hStdin = GetStdHandle(STD_INPUT_HANDLE)
			GetConsoleMode(hStdin, &mode)
			SetConsoleMode(hStdin, mode & ~DWORD(ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT))
		#else
			var raw = termios()
			tcgetattr(STDIN_FILENO, &originalTermios) // Get current terminal attributes
			raw = originalTermios
			#if os(Linux)
				raw.c_lflag &= ~UInt32(ECHO | ICANON) // Disable echo and canonical mode
			#else
				raw.c_lflag &= ~UInt(ECHO | ICANON) // Disable echo and canonical mode
			#endif
			tcsetattr(STDIN_FILENO, TCSANOW, &raw) // Apply raw mode
		#endif
	}

	// Restore original terminal attributes
	static func restoreOriginalMode() {
		#if os(Windows)
			var mode: DWORD = 0
			let hStdin = GetStdHandle(STD_INPUT_HANDLE)
			GetConsoleMode(hStdin, &mode)
			SetConsoleMode(hStdin, Int32(DWORD(mode | ENABLE_ECHO_INPUT | ENABLE_LINE_INPUT)))
		#else
			tcsetattr(STDIN_FILENO, TCSANOW, &originalTermios)
		#endif
	}

	// Read a single key press
	//! TODO: make this async so the program "pauses" until a key is pressed
	static func readKey() -> KeyboardKeys {
		#if os(Windows)
			WindowsTerminalInput.readKey()
		#else
			UnixTerminalInput.readKey()
		#endif
	}
}
