should.haveStatus = predicateActionBuilder
	test: (actual, expected) -> actual.status() == expected
	description: (fullName, expected) -> "View model status should be \"#{expected}\""
	error: (fullName, actual, expected) -> "Expected view model status to be \"#{expected}\" but was \"#{actual}\""

describe "OuterScenarioViewModel",
{
	"given a new OuterScenarioViewModel with no inner scenarios": ->
		parts =
			given:
				description: "given"
				actions: []
			dispose:
				description: "dispose"
				actions: []
		scenario = new Witness.OuterScenario parts, []
		@viewModel = new Witness.ViewModels.OuterScenarioViewModel scenario
	
	then:
		viewModel: should.haveStatus "notrun"
}
