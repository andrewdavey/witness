﻿# reference "../witness/dsl/describe.coffee"
# reference "../witness/Scenario.coffee"
# reference "../witness/Action.coffee"

describe "Scenario",
{
	"given a scenario with given, when, then and dispose": ->
		@scenario = new Witness.Scenario
			given:   { description: "given", actions: [ (new Witness.Action (=> @givenCalled = true), []) ] }
			when:    { description: "when", actions: [ (new Witness.Action (=> @whenCalled = true), []) ] }
			then:    { description: "then", actions: [ new Witness.Assertion (new Witness.Action (=> @thenCalled = true), []) ] }
			dispose: { description: "dispose", actions: [ (new Witness.Action (=> @disposeCalled = true), []) ] }

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
		@scenario = new Witness.Scenario 
			given:   { description: "given", actions: [ (new Witness.Action (-> throw new Error "given failed"), []) ] }
			when:    { description: "when", actions: [ (new Witness.Action (=> @whenCalled = true), []) ] }
			then:    { description: "then", actions: [ new Witness.Assertion (new Witness.Action (=> @thenCalled = true), []) ] }
			dispose: { description: "dispose", actions: [ (new Witness.Action (=> @disposeCalled = true), []) ] }


	"when scenarion is run": ->
		@scenario.run {}, (->), ((errors) => @errors = errors)

	then:
		whenCalled: should.be undefined
		thenCalled: should.be undefined
		disposeCalled: should.be true
		errors: [ message: should.be "given failed" ]
}
