import Foundation

protocol TypablePopup: PopUp, AnyObject {
	var isEditing: Bool { get set }
	var input: String { get set }
}

extension TypablePopup {}
