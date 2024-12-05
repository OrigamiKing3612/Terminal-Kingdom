enum MineTileEvent: TileEvent {
    case placeholder
    
    static func trigger(event: MineTileEvent) {
        switch event {
            case .placeholder:
                break
        }
    }
}
