enum UseStationEvent {
	static func useStation() {
		if case let .station(station: tile) = MapBox.tilePlayerIsOn.type {
			switch tile.type {
				case .anvil:
					UseAnvil.use()
				case let .furnace(progress: progress): // TODO: use the progress or remove it
					UseFurnace.use(progress: progress)
				case .workbench:
					UseWorkstation.use()
			}
		}
	}
}
