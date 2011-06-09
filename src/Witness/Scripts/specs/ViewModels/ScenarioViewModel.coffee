should.haveStatus = predicateActionBuilder
	test: (actual, expected) -> actual.status() == expected
	description: (fullName, expected) -> "View model status should be \"#{expected}\""
	error: (fullName, actual, expected) -> "Expected view model status to be \"#{expected}\" but was \"#{actual}\""
	
describe "ScenarioViewModel",
{
	given: ->
		@scenario = new Witness.Scenario([ new Witness.Action("given", (->), []) ],[],[],[])
		@viewModel = new Witness.ViewModels.ScenarioViewModel @scenario

	then:
		viewModel:
			this: should.haveStatus "notrun"
			givens: [ should.beInstanceof Witness.ViewModels.ActionWatcher ]
},
{
	given: ->
		@scenario = new Witness.Scenario([],[],[],[])
		@viewModel = new Witness.ViewModels.ScenarioViewModel @scenario

	when: ->
		@viewModel.run {}, (=> @doneCalled = true), (->)

	then:
		 doneCalled: should.be true
		 viewModel: should.haveStatus "passed"
},
{
	given: ->
		@scenario = new Witness.Scenario([ new Witness.Action("", (-> throw "scenario failed"), []) ],[],[],[])
		@viewModel = new Witness.ViewModels.ScenarioViewModel @scenario

	when: ->
		@viewModel.run {}, (->), ((error) => @error = error)

	then:
		 error: should.be "scenario failed"
		 viewModel: should.haveStatus "failed"
}