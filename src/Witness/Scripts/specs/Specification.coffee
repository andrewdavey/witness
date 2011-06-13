# reference "../witness/dsl/describe.coffee"
# reference "../witness/Specification.coffee"

describe "Specification",
{
	"given a Specification with two scenarios": ->
		@specification = new Witness.Specification(
			"specification description"
			[ new Witness.Scenario([],[],[],[]), new Witness.Scenario([],[],[],[]) ]
		)

	then:
		specification:
			description: should.be "specification description"
			scenarios: length: should.be 2
}
