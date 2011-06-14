should.haveStatus = predicateActionBuilder
	test: (actual, expected) -> actual.status() == expected
	description: (fullName, expected) -> "View model status should be \"#{expected}\""
	error: (fullName, actual, expected) -> "Expected view model status to be \"#{expected}\" but was \"#{actual.status()}\""
	
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
			this: should.haveStatus "notrun"
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
		 viewModel: should.haveStatus "passed"
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
		 viewModel: should.haveStatus "failed"
}
