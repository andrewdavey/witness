# reference "../witness/dsl/describe.coffee"
# reference "../witness/AsyncAction.coffee"

describe "AsyncAction",
{
	given: ->
		functionThatCallsDone = -> setTimeout (=> this.done()), 20
		@action = new Witness.AsyncAction "name", functionThatCallsDone, []

	when: async ->
		testDone = @done;
		@action.run {}, (=> @doneCalled = true; testDone()), (=> @failCalled = true; testDone())

	then: [
		-> @doneCalled == true
		-> not @failCalled
	]
},
{
	given: ->
		functionThatCallsFail = -> setTimeout (=> this.fail "failed"), 20
		@action = new Witness.AsyncAction "name", functionThatCallsFail, []

	when: async ->
		testDone = @done;
		@action.run {}, (=> @doneCalled = true; testDone()), ((error) => @error = error; testDone())

	then: [
		-> not @doneCalled
		-> @error == "failed"
	]
},
{
	given: ->
		functionThatDoesNothing = (->)
		timeToWait = 100 # milliseconds
		@action = new Witness.AsyncAction "name", functionThatDoesNothing, [], timeToWait

	when: async ->
		testDone = @done;
		@action.run {}, (=> @doneCalled = true; testDone()), ((error) => @error = error; testDone())

	then: [
		-> not @doneCalled
		-> @error instanceof Witness.TimeoutError
	]
},
{
	given: ->
		functionThatThrowsBeforeAsync = -> throw new Error "failed"
		@action = new Witness.AsyncAction "name", functionThatThrowsBeforeAsync, []

	when: async ->
		testDone = @done;
		@action.run {}, (=> @doneCalled = true; testDone()), ((error) => @error = error; testDone())

	then: [
		-> not @doneCalled
		-> @error.message == "failed"
	]
}