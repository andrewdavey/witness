# reference "../witness/dsl/describe.coffee"
# reference "../witness/Assertion.coffee"

actionThatReturns = (result) -> new Witness.Action (-> result)
actionThatThrows = new Witness.Action (-> throw new Error "custom error")

describe "Assertion",
{
	given: ->
		@assertion = new Witness.Assertion actionThatReturns true

	when: ->
		@assertion.run {}, (=> @doneCallbackCalled = true), (-> @failCallbackCalled = true)
	
	then:
		doneCallbackCalled: should.be true
		failCallbackCalled: should.be undefined
},
{
	given: ->
		@assertion = new Witness.Assertion actionThatReturns false

	when: ->
		@assertion.run {}, (=> @doneCallbackCalled = true), (=> @failCallbackCalled = true)
	
	then:
		doneCallbackCalled: should.be undefined
		failCallbackCalled: should.be true
},
{
	given: ->
		@assertion = new Witness.Assertion actionThatThrows

	when: ->
		@assertion.run {}, (=> @doneCallbackCalled = true), ((error) => @error = error)
	
	then:
		doneCallbackCalled: should.be undefined
		error: message: should.be "custom error"
}
