import Foundation
#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

enum KeyboardKeys: String {
    case up
    case down
    case right
    case left
    case unknown
    case a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
    case A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
    case space = " "
    case backspace
    case enter
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    
    var isLetter: Bool {
        switch self {
            case .a,.b,.c,.d,.e,.f,.g,.h,.i,.j,.k,.l,.m,.n,.o,.p,.q,.r,.s,.t,.u,.v,.w,.x,.y,.z: return true
            case .A,.B,.C,.D,.E,.F,.G,.H,.I,.J,.K,.L,.M,.N,.O,.P,.Q,.R,.S,.T,.U,.V,.W,.X,.Y,.Z: return true
            default: return false
        }
    }
    var isNumber: Bool {
        switch self {
            case .one,.two,.three,.four,.five,.six,.seven,.eight,.nine,.zero: return true
            default: return false
        }
    }
}

struct TerminalInput {
    @MainActor private static var originalTermios = termios()
    
    // Enable raw mode
    @MainActor static func enableRawMode() {
        var raw = termios()
        tcgetattr(STDIN_FILENO, &originalTermios) // Get current terminal attributes
        raw = originalTermios
#if os(Linux)
        raw.c_lflag &= ~(UInt32(ECHO | ICANON)) // Disable echo and canonical mode
#else
        raw.c_lflag &= ~(UInt(ECHO | ICANON)) // Disable echo and canonical mode
#endif
        tcsetattr(STDIN_FILENO, TCSANOW, &raw) // Apply raw mode
    }
    
    // Restore original terminal attributes
    @MainActor static func restoreOriginalMode() {
        tcsetattr(STDIN_FILENO, TCSANOW, &originalTermios)
    }
    
    // Read a single key press
    static func readKey() -> KeyboardKeys {
        var buffer = [UInt8](repeating: 0, count: 3)
        read(STDIN_FILENO, &buffer, 3)
        
        if buffer[0] == 27 { // Escape character
            if buffer[1] == 91 { // CSI (Control Sequence Introducer)
                switch buffer[2] {
                    case 65: return .up
                    case 66: return .down
                    case 67: return .right
                    case 68: return .left
                    default: return .unknown
                }
            }
            return .unknown
        } else if buffer[0] == 13 {
            return .enter
        } else if buffer[0] == 10 {
            return .enter
        } else if buffer[0] == 32 {
            return .space
        } else if buffer[0] == 8 || buffer[0] == 127 {
            return .backspace
        } else if buffer[0] >= 48 && buffer[0] <= 57 { // Numeric characters
            switch buffer[0] {
                case 48: return .zero
                case 49: return .one
                case 50: return .two
                case 51: return .three
                case 52: return .four
                case 53: return .five
                case 54: return .six
                case 55: return .seven
                case 56: return .eight
                case 57: return .nine
                default: return .unknown
            }
        } else if buffer[0] >= 32 && buffer[0] <= 126 { // Printable characters
            return KeyboardKeys(rawValue: String(UnicodeScalar(buffer[0]))) ?? .unknown
        }
        
        return .unknown
    }
}
