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

//TODO: make this work on linux and macos

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
            case .p:
                switch MapBox.mapType {
                    case .mainMap:
                        let x = MapBox.player.x
                        let y = MapBox.player.y
                        MessageBox.message("x: \(x); y: \(y)", speaker: .dev)
                    case .mining:
                        break
                    default:
                        let x = MapBox.buildingMap.player.x
                        let y = MapBox.buildingMap.player.y
                        MessageBox.message("x: \(x); y: \(y)", speaker: .dev)
                }
            case .o:
                let tile = MapBox.mapType.map.tilePlayerIsOn
                if let event = tile.event {
                    MessageBox.message("tileType: \(tile.type.name), tileEvent: \(event.name), isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType)", speaker: .dev)
                } else {
                    MessageBox.message("tileType: \(tile.type.name), tileEvent: nil, isWalkable: \(tile.isWalkable), mapType: \(MapBox.mapType)", speaker: .dev)
                }

            default:
                MessageBox.message("You pressed: \(key.rawValue)", speaker: .game)
        }
    }
}
