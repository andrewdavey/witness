# reference "../witness/dsl/describe.coffee"
# reference "../witness/Assertion.coffee"

actionThatReturns = (result) -> new witness.Action (-> result)
actionThatThrows = new witness.Action (-> throw new Error "custom error")

describe "Assertion",
{
	"given an assertion where the action returns true": ->
		@assertion = new witness.Assertion actionThatReturns true

	"when the assertion is run": ->
		@assertion.run {}, (=> @doneCallbackCalled = true), (-> @failCallbackCalled = true)
	
	then:
		doneCallbackCalled: should.be true
		failCallbackCalled: should.be undefined
},
{
	"given an assertion where the action returns false": ->
		@assertion = new witness.Assertion actionThatReturns false

	"when the assertion is run": ->
		@assertion.run {}, (=> @doneCallbackCalled = true), (=> @failCallbackCalled = true)
	
	then:
		doneCallbackCalled: should.be undefined
		failCallbackCalled: should.be true
},
{
	"given an assertion where the action throws": ->
		@assertion = new witness.Assertion actionThatThrows

	"when the assertion is run": ->
		@assertion.run {}, (=> @doneCallbackCalled = true), ((error) => @error = error)
	
	then:
		doneCallbackCalled: should.be undefined
		error: message: should.be "custom error"
}
