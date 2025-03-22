import Foundation

protocol DoorEvent {
	static func open(tile: DoorTile) async
	static func goInside(tile: DoorTile) async
}
