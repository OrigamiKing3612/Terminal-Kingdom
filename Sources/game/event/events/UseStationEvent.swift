enum UseStationEvent {
	static func useStation() async {
		if case let .station(station: tile) = await MapBox.tilePlayerIsOn.type {
			// TODO: make popups
			switch tile.type {
				case .anvil:
					await UseAnvil.use()
				case let .furnace(progress: progress): // TODO: use the progress or remove it
					await UseFurnace.use(progress: progress)
				case .workbench:
					await UseWorkbench.use()
			}
		}
	}
}
