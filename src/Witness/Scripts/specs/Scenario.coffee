# reference "../witness/dsl/describe.coffee"
# reference "../witness/Scenario.coffee"
# reference "../witness/Action.coffee"

describe "Scenario",
{
	given: ->
		givens = [ (new Witness.Action "given-action", (=> @givenCalled = true), []) ]
		whens = [ (new Witness.Action "when-action", (=> @whenCalled = true), []) ]
		thens = [ (new Witness.Action "then-assertion", (=> @thenCalled = true), []) ]
		disposes = [ (new Witness.Action "dispose-action", (=> @disposeCalled = true), []) ]
		@scenario = new Witness.Scenario givens, whens, thens, disposes

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
		givens = [ (new Witness.Action "given-action", (-> throw new Error "given failed"), []) ]
		whens = [ (new Witness.Action "when-action", (=> @whenCalled = true), []) ]
		thens = [ (new Witness.Action "then-assertion", (=> @thenCalled = true), []) ]
		disposes = [ (new Witness.Action "dispose-action", (=> @disposeCalled = true), []) ]
		@scenario = new Witness.Scenario givens, whens, thens, disposes

	when: ->
		@scenario.run {}, (->), ((errors) => @errors = errors)

	then:
		whenCalled: should.be undefined
		thenCalled: should.be undefined
		disposeCalled: should.be true
		errors: [ message: should.be "given failed" ]
}