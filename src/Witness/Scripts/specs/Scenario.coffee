# reference "../witness/dsl/describe.coffee"
# reference "../witness/Scenario.coffee"
# reference "../witness/Action.coffee"

describe "Scenario",
{
	given: ->
		@scenario = new Witness.Scenario
			given:   { description: "given", actions: [ (new Witness.Action "given-action",   (=> @givenCalled = true), []) ] }
			when:    { description: "when", actions: [ (new Witness.Action "when-action",    (=> @whenCalled = true), []) ] }
			then:    { description: "then", actions: [ (new Witness.Action "then-assertion", (=> @thenCalled = true), []) ] }
			dispose: { description: "dispose", actions: [ (new Witness.Action "dispose-action", (=> @disposeCalled = true), []) ] }

	when: ->
		@scenario.run {}, (->), (->)

	then:
		givenCalled: should.be true
		whenCalled: should.be true
		thenCalled: should.be true
		disposeCalled: should.be true
},
{
	given: ->
		@scenario = new Witness.Scenario 
			given:   { description: "given", actions: [ (new Witness.Action "given-action",   (-> throw new Error "given failed"), []) ] }
			when:    { description: "when", actions: [ (new Witness.Action "when-action",    (=> @whenCalled = true), []) ] }
			then:    { description: "then", actions: [ (new Witness.Action "then-assertion", (=> @thenCalled = true), []) ] }
			dispose: { description: "dispose", actions: [ (new Witness.Action "dispose-action", (=> @disposeCalled = true), []) ] }


	when: ->
		@scenario.run {}, (->), ((errors) => @errors = errors)

	then:
		whenCalled: should.be undefined
		thenCalled: should.be undefined
		disposeCalled: should.be true
		errors: [ message: should.be "given failed" ]
}
