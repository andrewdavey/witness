describe "ScenarioViewModel",
{
	"given a ScenarioViewModel with a given part": ->
		@scenario = new witness.Scenario
			given:
				description: "given"
				actions: [
					new witness.Action((->), [], "action")
				]
		@viewModel = new witness.ViewModels.ScenarioViewModel @scenario

	then:
		viewModel:
			status: should.be "notrun"
			givens: [ should.beInstanceof witness.ViewModels.ActionWatcher ]
},
{
	"given a ScenarioViewModel with no parts": ->
		@scenario = new witness.Scenario([],[],[],[])
		@viewModel = new witness.ViewModels.ScenarioViewModel @scenario

	"when it is run": ->
		@viewModel.run()

	then:
		 viewModel: status: should.be "passed"
},
{
	"given a ScenarioViewModel with a given part that throws": ->
		@scenario = new witness.Scenario
			given:
				description: "given"
				actions: [
					new witness.Action (-> throw new Error "scenario failed"), [], "action"
				]
		@viewModel = new witness.ViewModels.ScenarioViewModel @scenario

	"when it is run": ->
		@viewModel.run()

	then: [
		 viewModel: status: should.be "failed"
		 -> @viewModel.errors()[0].message == "scenario failed"
	]
}
