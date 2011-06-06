# reference "../witness/describe.coffee"
# reference "../witness/Scenario.coffee"
# reference "../witness/Action.coffee"

describe "Scenario",
{
	given: ->
		givens = [ (new Witness.Action "given-action", (=> @givenCalled = true), []) ]
		whens = [ (new Witness.Action "when-action", (=> @whenCalled = true), []) ]
		thens = [ (new Witness.Assertion "then-assertion", (=> @thenCalled = true), []) ]
		disposes = [ (new Witness.Action "dispose-action", (=> @disposeCalled = true), []) ]
		@scenario = new Witness.Scenario givens, whens, thens, disposes

	when: ->
		@scenario.run {}, (->), (->)

	then: [
		-> @givenCalled == true
		-> @whenCalled == true
		-> @thenCalled == true
		-> @disposeCalled == true
	]
},
{
	given: ->
		givens = [ (new Witness.Action "given-action", (-> throw new Error "given failed"), []) ]
		whens = [ (new Witness.Action "when-action", (=> @whenCalled = true), []) ]
		thens = [ (new Witness.Assertion "then-assertion", (=> @thenCalled = true), []) ]
		disposes = [ (new Witness.Action "dispose-action", (=> @disposeCalled = true), []) ]
		@scenario = new Witness.Scenario givens, whens, thens, disposes

	when: ->
		@scenario.run {}, (->), ((errors) => @errors = errors)

	then: [
		-> not @whenCalled
		-> not @thenCalled
		-> @disposeCalled == true
		-> @errors[0].message == "given failed"
	]
}