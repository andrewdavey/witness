# reference "../witness/dsl/describe.coffee"
# reference "../witness/Specification.coffee"

describe "Specification",
{
	given: ->
		@specification = new Witness.Specification(
			"specification description"
			[ new Witness.Scenario([],[],[],[]), new Witness.Scenario([],[],[],[]) ]
		)

	then: [
		-> @specification.description == "specification description"
		-> @specification.scenarios.length == 2
	]
}