# reference "../witness/dsl/describe.coffee"
# reference "../witness/AsyncAction.coffee"

describe "AsyncAction",
{
	given: ->
		functionThatThrowsBeforeAsync = -> throw new Error "failed"
		@action = new Witness.AsyncAction functionThatThrowsBeforeAsync, []

	when: async ->
		testDone = @done;
		@action.run {}, (=> @doneCalled = true; testDone()), ((error) => @error = error; testDone())

	then:
		doneCalled: should.be undefined
		error: message: should.be "failed"
},
{
	given: ->
		functionThatDoesNothing = (->)
		timeToWait = 10 # milliseconds
		@action = new Witness.AsyncAction functionThatDoesNothing, [], null, timeToWait

	when: async ->
		testDone = @done;
		@action.run {}, (=> @doneCalled = true; testDone()), ((error) => @error = error; testDone())

	then:
		doneCalled: should.be undefined
		error: should.beInstanceof Witness.TimeoutError
},
{
	given: ->
		functionThatCallsDone = -> setTimeout (=> this.done()), 100
		@action = new Witness.AsyncAction functionThatCallsDone

	when: async ->
		testDone = @done;
		@action.run {}, (=> @doneCalled = true; testDone()), (=> @failCalled = true; testDone())

	then:
		doneCalled: should.be true
		failCalled: should.be undefined
},
{
	given: ->
		functionThatCallsFail = -> setTimeout (=> this.fail "failed"), 10
		@action = new Witness.AsyncAction functionThatCallsFail

	when: async ->
		testDone = @done;
		@action.run {}, (=> @doneCalled = true; testDone()), ((error) => @error = error; testDone())

	then:
		doneCalled: should.be undefined
		error: should.be "failed"
}
