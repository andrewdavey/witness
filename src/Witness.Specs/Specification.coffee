# reference "../witness/dsl/describe.coffee"
# reference "../witness/Specification.coffee"

describe "Specification",
{
	"given a Specification with two scenarios": ->
		@specification = new witness.Specification(
			"specification description"
			[ new witness.Scenario([],[],[],[]), new witness.Scenario([],[],[],[]) ]
		)

	then:
		specification:
			description: should.be "specification description"
			scenarios: length: should.be 2
}
