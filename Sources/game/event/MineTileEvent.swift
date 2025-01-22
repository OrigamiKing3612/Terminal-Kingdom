enum MineTileEvent: TileEvent {
	case placeholder

	static func trigger(event: MineTileEvent) async {
		switch event {
			case .placeholder:
				break
		}
	}

	var name: String {
		switch self {
			case .placeholder: "Placeholder"
		}
	}
}
