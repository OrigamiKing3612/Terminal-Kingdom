import Foundation
import Darwin

Screen.clear()
Screen.Cursor.moveToTop()

TerminalInput.enableRawMode()

defer {
    TerminalInput.restoreOriginalMode()
}

if Game.hasInited == false {
    Game.initGame()
    Screen.initialize()
    if prePreGame() {
        
    } else {
        MessageBox.message("Welcome to Adventure!", speaker: .game)
        preGame()
    }
    mainGameLoop()
}

func endProgram() {
//    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//    if let filePath {
//        let file = filePath.appendingPathComponent("adventure.game.json")
//
//        do {
//            let game = CodableGame(location: Game.location, hasInited: Game.hasInited, isTypingInMessageBox: Game.isTypingInMessageBox, player: Game.player, map: Game.map, startingVillageChecks: Game.startingVillageChecks, stages: Game.stages, messages: Game.messages)
//            let JSON = try JSONEncoder().encode(game)
//            try JSON.write(to: filePath)
//        } catch {
//            
//        }
//    }
    exit(0)
}

func prePreGame() -> Bool {
    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    if let filePath {
        let file = filePath.appendingPathComponent("adventure.game.json")
        do {
            let fileData = try Data(contentsOf: file)
            let decodedGame = try JSONDecoder().decode(CodableGame.self, from: fileData)
            Game.reloadGame(decodedGame: decodedGame)
            return true
        } catch {
            // print("Error reading or decoding the file: \(error)")
        }
    }
    return false
}

func preGame() {
    let playerName = MessageBox.messageWithTyping("Let's create your character. What is your name?", speaker: .game)
    MessageBox.message("Welcome \(playerName)!", speaker: .game)
    Game.player.setName(playerName)
    StatusBox.statusBox()
}

func mainGameLoop() {
    while true {
        InventoryBox.printInventory()
        
        guard !Game.isTypingInMessageBox else { continue }
        
        let key = TerminalInput.readKey()
        switch key {
            case .q:
                endProgram()
            case .w, .up:
                MapBox.movePlayer(.up)
            case .a, .left:
                MapBox.movePlayer(.left)
            case .s, .down:
                MapBox.movePlayer(.down)
            case .d, .right:
                MapBox.movePlayer(.right)
            case .space, .enter, .i:
                MapBox.interactWithTile()
            case .l where MapBox.mapType == .mining:
                MapBox.mapType = .mine
                MapBox.buildingMap.player.x = 2
                MapBox.buildingMap.player.y = 2
                MapBox.mapBox()
            default:
                MessageBox.message("You pressed: \(key.rawValue)", speaker: .game)
        }
    }
}
