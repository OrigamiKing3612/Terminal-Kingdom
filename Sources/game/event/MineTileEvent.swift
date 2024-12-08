enum MineTileEvent: TileEvent {
    case placeholder
    
    static func trigger(event: MineTileEvent) {
        switch event {
            case .placeholder:
                break
        }
    }
    var name: String {
        switch self {
            case .placeholder: return "Placeholder"
        }
    }
}
