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
		viewModel:
			givenDescription: should.be "given"
			status: should.be "notrun"
			isOpen: should.be true
			innerScenarios: length: should.be 0
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

	"when it is run": [
		-> @viewModel.run()
		wait 100
	]

	then:
		viewModel: status: should.be "passed"
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
		scenario = new Witness.OuterScenario parts, [ new Witness.Scenario {} ]
		@viewModel = new Witness.ViewModels.OuterScenarioViewModel scenario
	
	"when it is run": [
		-> @viewModel.run()
		wait 100
	]

	then:
		viewModel: status: should.be "failed"
}
