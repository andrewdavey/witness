# reference "../witness/dsl/describe.coffee"
# reference "../witness/Scenario.coffee"
# reference "../witness/Action.coffee"

describe "Scenario",
{
	"given a scenario with given, when, then and dispose": ->
		@scenario = new witness.Scenario
			given:   { description: "given", actions: [ (new witness.Action (=> @givenCalled = true), []) ] }
			when:    { description: "when", actions: [ (new witness.Action (=> @whenCalled = true), []) ] }
			then:    { description: "then", actions: [ new witness.Assertion (new witness.Action (=> @thenCalled = true), []) ] }
			dispose: { description: "dispose", actions: [ (new witness.Action (=> @disposeCalled = true), []) ] }

	"when scenario is run": ->
		@scenario.run {}, (->), (->)

	then:
		givenCalled: should.be true
		whenCalled: should.be true
		thenCalled: should.be true
		disposeCalled: should.be true
},
{
	"given a scenario where the `given` action throws an error": ->
		@scenario = new witness.Scenario 
			given:   { description: "given", actions: [ (new witness.Action (-> throw new Error "given failed"), []) ] }
			when:    { description: "when", actions: [ (new witness.Action (=> @whenCalled = true), []) ] }
			then:    { description: "then", actions: [ new witness.Assertion (new witness.Action (=> @thenCalled = true), []) ] }
			dispose: { description: "dispose", actions: [ (new witness.Action (=> @disposeCalled = true), []) ] }


	"when scenarion is run": ->
		@scenario.run {}, (->), ((errors) => @errors = errors)

	then:
		whenCalled: should.be undefined
		thenCalled: should.be undefined
		disposeCalled: should.be true
		errors: [ message: should.be "given failed" ]
}
