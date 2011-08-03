# reference "../witness/dsl/describe.coffee"
# reference "../witness/AsyncAction.coffee"

describe "AsyncAction",
{
	"given an AsyncAction where the function throws before going async": ->
		functionThatThrowsBeforeAsync = -> throw new Error "failed"
		@action = new witness.AsyncAction functionThatThrowsBeforeAsync, []

	"when the action is run": async ->
		testDone = @done
		@action.run {}, (=> @doneCalled = true; testDone()), ((error) => @error = error; testDone())

	then:
		doneCalled: should.be undefined
		error: message: should.be "failed"
},
{
	"given an AsyncAction where the function does nothing and timeout is 10 milliseconds": ->
		functionThatDoesNothing = (->)
		timeToWait = 10 # milliseconds
		@action = new witness.AsyncAction functionThatDoesNothing, [], null, timeToWait

	"when the action is run": async ->
		testDone = @done
		@action.run {}, (=> @doneCalled = true; testDone()), ((error) => @error = error; testDone())

	then:
		doneCalled: should.be undefined
		error: should.beInstanceof witness.TimeoutError
},
{
	"given an AsyncAction where the function calls done after a 100 millisecond delay": ->
		functionThatCallsDone = -> setTimeout (=> this.done()), 100
		@action = new witness.AsyncAction functionThatCallsDone

	"when the action is run": async ->
		testDone = @done
		@action.run {}, (=> @doneCalled = true; testDone()), (=> @failCalled = true; testDone())

	then:
		doneCalled: should.be true
		failCalled: should.be undefined
},
{
	"given an AsyncAction where the function calls fail": ->
		functionThatCallsFail = -> setTimeout (=> this.fail "failed"), 10
		@action = new witness.AsyncAction functionThatCallsFail

	"when the action is run": async ->
		testDone = @done
		@action.run {}, (=> @doneCalled = true; testDone()), ((error) => @error = error; testDone())

	then:
		doneCalled: should.be undefined
		error: should.be "failed"
},
{
	"given an AsyncAction that requires a result": ->
		@action = new witness.AsyncAction -> @done(42)
		
	"when the action is run": ->
		@action.run {}, ((result)=>@result = result), (->)
		
	"then the result is passed to the done callback":
		result: should.be 42
},
{
	"given an AsyncAction": ->
		@action = new witness.AsyncAction -> @done()

	"when setTimeout called": ->
		@result = @action.setTimeout 666

	"then timeout property assigned":
		action: timeout: should.be 666

	"then the action is returned to allow chaining":
		-> @result == @action
}
