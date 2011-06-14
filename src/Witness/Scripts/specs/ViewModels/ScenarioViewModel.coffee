should.unwrapActual = (actual) -> 
	if actual.__ko_proto__?
		actual()
	else
		actual

describe "ScenarioViewModel",
{
	"given a ScenarioViewModel with a given part": ->
		@scenario = new Witness.Scenario
			given:
				description: "given"
				actions: [
					new Witness.Action((->), [], "action")
				]
		@viewModel = new Witness.ViewModels.ScenarioViewModel @scenario

	then:
		viewModel:
			status: should.be "notrun"
			givens: [ should.beInstanceof Witness.ViewModels.ActionWatcher ]
},
{
	"given a ScenarioViewModel with no parts": ->
		@scenario = new Witness.Scenario([],[],[],[])
		@viewModel = new Witness.ViewModels.ScenarioViewModel @scenario

	"when it is run": ->
		@viewModel.run {}, (=> @doneCalled = true), (->)

	then:
		 doneCalled: should.be true
		 viewModel: status: should.be "passed"
},
{
	"given a ScenarioViewModel with a given part that throws": ->
		@scenario = new Witness.Scenario
			given:
				description: "given"
				actions: [
					new Witness.Action (-> throw "scenario failed"), [], "action"
				]
		@viewModel = new Witness.ViewModels.ScenarioViewModel @scenario

	"when it is run": ->
		@viewModel.run {}, (->), ((error) => @error = error)

	then:
		 error: should.be "scenario failed"
		 viewModel: status: should.be "failed"
}
