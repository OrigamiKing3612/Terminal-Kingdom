enum MineTileEvent: Codable {
    case placeholder
    
    static func trigger(event: MineTileEvent) {
        switch event {
            case .placeholder:
                break
        }
    }
}
