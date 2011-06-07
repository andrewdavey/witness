# reference "../witness/dsl/describe.coffee"
# reference "../witness/Assertion.coffee"

delayedDoneCall = (result) -> (-> setTimeout (=> this.done result), 20)

functionThatCallsDoneWithTrue      = delayedDoneCall true
functionThatCallsDoneWithFalse     = delayedDoneCall false
functionThatCallsDoneWithUndefined = delayedDoneCall()
functionThatThrows                 = -> throw new Error "failed"

afterRun = (func, assertions) -> {
	given: ->
		@assertion = new Witness.AsyncAssertion "name", func, []
	when: async ->
		testDone = @done
		@assertion.run {}, (=> @doneCallbackCalled = true; testDone()), ((error) => @error = error; testDone())
	then: assertions
}

describe "AsyncAssertion",
	afterRun(functionThatCallsDoneWithTrue, [
		-> @doneCallbackCalled
		-> not @error
	]),
	afterRun(functionThatCallsDoneWithFalse, [
		-> not @doneCallbackCalled
		-> @error.message == "Assertion failed: name"
	]),
	afterRun(functionThatCallsDoneWithUndefined, [
		-> @doneCallbackCalled
		-> not @error
	]),
	afterRun(functionThatThrows, [
		-> not @doneCallbackCalled
		-> @error.message == "failed"
	])

