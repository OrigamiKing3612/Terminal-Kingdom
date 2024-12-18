struct StatusBox {
    static var quests: [Quest] {
        Game.player.quests
    }

    nonisolated(unsafe) static var showStatusBox = true {
        didSet {
            if showStatusBox {
                statusBox()
            } else {
                clear()
            }
        }
    }

    static let questBoxStartX = q4StartX + 1
    static let questBoxEndX = q4StartX + (q4Width / 2) // Halfway point of the 4th quadrant
    static var questBoxWidth: Int {
        questBoxEndX - questBoxStartX
    }

    static let questBoxStartY = q4StartY + 1
    static let questBoxEndY = q4EndY
    static var questBoxHeight: Int {
        abs((q4StartY + 1) - 2)
    }

    static let statusAreaEndX = q4EndX - 1
    static var statusAreaWidth: Int {
        questBoxEndX - questBoxStartX
    }

    static let statusAreaStartY = q4StartY + 1
    static let statusAreaEndY = q4EndY
    static var statusAreaHeight: Int {
        abs((q4StartY + 1) - 2)
    }


    static func statusBox() {
        clear()

        Screen.print(x: q4StartX, y: q4StartY, String(repeating: "=", count: q4Width + 3))
        for y in (q4StartY + 1)..<q4EndY {
            Screen.print(x: q4StartX, y: y, "|")
            Screen.print(x: q4EndX, y: y, "|")
        }
        if !quests.isEmpty {
            questBox()
        }
        statusArea(startX: !quests.isEmpty ? questBoxEndX + 1 : q4StartX + 1)

        Screen.print(x: q4StartX, y: q4EndY, String(repeating: "=", count: q4Width + 3))
    }

    static func statusArea(startX: Int) {
        if !(Game.player.name == "") {
            Screen.print(x: startX, y: statusAreaStartY, "\(Game.player.name):")
        }
        var yValueToPrint = statusAreaStartY + 1
        for skillLevel in AllSkillLevels.allCases {
            if skillLevel.stat.rawValue > 0 {
                var count = ""
                for _ in 0..<skillLevel.stat.rawValue {
                    count += "#"
                }
                Screen.print(x: startX, y: yValueToPrint, "\(skillLevel.name): \(count)")
                yValueToPrint += 1
            }
        }
    }

    static func questBox() {
        for y in (questBoxStartY)..<questBoxEndY {
            Screen.print(x: questBoxStartX - 1, y: y, "|")
            Screen.print(x: questBoxEndX, y: y, "|")
        }

        let maxVisibleLines = q4Height - 2
        var renderedLines: [String] = []

        Screen.print(x: questBoxStartX, y: questBoxStartY, "Quests:")

        for quest in quests {
            if quest.label.count >= questBoxWidth - 1 {
                var currentLineStart = quest.label.startIndex
                while currentLineStart < quest.label.endIndex {
                    let lineEnd = quest.label.index(currentLineStart, offsetBy: questBoxWidth - 2, limitedBy: quest.label.endIndex) ?? quest.label.endIndex
                    let line = String(quest.label[currentLineStart..<lineEnd])
                    renderedLines.append(line)
                    currentLineStart = lineEnd
                }
            } else {
                renderedLines.append(quest.label)
            }
        }
        if renderedLines.count > maxVisibleLines {
            let overflow = renderedLines.count - maxVisibleLines
            renderedLines.removeFirst(overflow)
        }

        var currentY = questBoxStartY + 1
        for line in renderedLines {
            Screen.print(x: questBoxStartX, y: currentY, line)
            currentY += 1
        }
    }

    static func clear() {
        let spaceString = String(repeating: " ", count: q4Width + 2)
        for y in (q4StartY + 1)..<q4EndY {
            Screen.print(x: q4StartX + 1, y: y, spaceString)
        }
    }

    static func clearQuestBox() {
        let blankLine = String(repeating: " ", count: questBoxWidth - 2)
        for y in (questBoxStartY + 1)..<questBoxEndY {
            Screen.print(x: questBoxStartX + 1, y: y, blankLine)
        }
    }

    static func quest(_ quest: Quest) {
        clear()
        Game.player.addQuest(quest)
        statusBox()
    }

    static func removeQuest(quest: Quest) {
        clear()
        Game.player.removeQuest(quest: quest)
        statusBox()
    }

    static func removeQuest(index: Int) {
        clear()
        Game.player.removeQuest(index: index)
        statusBox()
    }

    @discardableResult
    static func removeLastQuest() -> Quest {
        Game.player.removeLastQuest()
    }

    static func updateLastQuest(newQuest: Quest) {
        Game.player.updateLastQuest(newQuest: newQuest)
        statusBox()
    }
}
