should.haveStatus = predicateActionBuilder
	test: (actual, expected) -> actual.status() == expected
	description: (fullName, expected) -> "View model status should be \"#{expected}\""
	error: (fullName, actual, expected) -> "Expected view model status to be \"#{expected}\" but was \"#{actual.status()}\""

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
},
{
	"given an OuterScenarioViewModel": ->
		parts =
			given:
				description: "given"
				actions: []
			dispose:
				description: "dispose"
				actions: []
		scenario = new Witness.OuterScenario parts, []
		@viewModel = new Witness.ViewModels.OuterScenarioViewModel scenario

	"when it is run": ->
		@viewModel.run {}, (->), (->)
	
	then:
		viewModel: should.haveStatus "passed"
},
{
	"given an OuterScenarioViewModel where the Scenario fails": ->
		parts =
			given:
				description: "given"
				actions: [ new Witness.Action (-> throw new Error "failed") ]
			dispose:
				description: "dispose"
				actions: []
		scenario = new Witness.OuterScenario parts, []
		@viewModel = new Witness.ViewModels.OuterScenarioViewModel scenario
	
	"when it is run": ->
		@viewModel.run {}, (->), (->)

	then:
		viewModel: should.haveStatus "failed"
}
