import Foundation
import Darwin

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
    
    var isLetter: Bool {
        switch self {
            case .a,.b,.c,.d,.e,.f,.g,.h,.i,.j,.k,.l,.m,.n,.o,.p,.q,.r,.s,.t,.u,.v,.w,.x,.y,.z: return true
            case .A,.B,.C,.D,.E,.F,.G,.H,.I,.J,.K,.L,.M,.N,.O,.P,.Q,.R,.S,.T,.U,.V,.W,.X,.Y,.Z: return true
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
        
        raw.c_lflag &= ~(UInt(ECHO | ICANON)) // Disable echo and canonical mode
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
        } else if buffer[0] >= 32 && buffer[0] <= 126 { // Printable characters
            let char = Character(UnicodeScalar(buffer[0]))
            
            if char.isUppercase {
                return KeyboardKeys(rawValue: String(char).capitalized) ?? .unknown
            } else {
                return KeyboardKeys(rawValue: String(char).lowercased()) ?? .unknown
            }
        }
        
        return .unknown
    }
}
