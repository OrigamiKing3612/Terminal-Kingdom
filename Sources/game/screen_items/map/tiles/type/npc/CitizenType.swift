import Foundation

struct CitizenType: Codable, Equatable, Hashable, Identifiable {
	let id: UUID
	let name: String
	// let age: Int
	let gender: Gender

	init(id: UUID = UUID(), name: String? = nil /* , age: Int? = nil */, gender: Gender? = nil) {
		self.id = id
		self.gender = gender ?? Gender.allCases.randomElement()!
		self.name = name ?? CitizenType.generateRandomName(for: self.gender)
		// self.age = age ?? Int.random(in: 18 ... 80)
	}

	static func generateRandomName(for gender: Gender) -> String {
		let maleNames = [
			"Adam", "Ben", "Caleb", "Daniel", "Eric",
			"Felix", "Greg", "Henry", "Isaac", "Jack",
			"Kyle", "Leo", "Matt", "Nate", "Owen",
			"Paul", "Quinn", "Ryan", "Sam", "Tom",
			"Victor", "Theo", "Jim", "Eli", "Mark",
		]

		let femaleNames = [
			"Anna", "Beth", "Chloe", "Daisy", "Emma",
			"Faith", "Grace", "Hannah", "Ivy", "Julia",
			"Kate", "Lily", "Mia", "Nora", "Olivia",
			"Paige", "Jordan", "Rachel", "Sarah", "Tessa",
			"Violet", "Wendy", "Zoey", "Ellie", "Claire",
		]

		return (gender == .male ? maleNames : femaleNames).randomElement()!
	}
}

enum Gender: String, Codable, CaseIterable {
	case male, female
}
