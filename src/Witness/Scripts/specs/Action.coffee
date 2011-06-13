# reference "../witness/dsl/describe.coffee"
# reference "../witness/Action.coffee"

describe "Action",
{
	"given an action that does nothing": ->
		@testContext = {}
		@action = new Witness.Action (->)
		
	"when the action is run": ->
		testContext = @testContext
		@action.run(
			testContext,
			(() =>
				@doneCallbackCalled = true
				@doneContext = testContext),
			(() => @failCallbackCalled = true)
		)
	
	then:
		doneCallbackCalled: should.be true
		doneContext: should.be -> @testContext
		failCallbackCalled: should.be undefined
},
{
	"given an action that throws an error": ->
		@testContext = {}
		@action = new Witness.Action (-> throw new Error "failed")
		
	"when the action is run": ->
		testContext = @testContext
		@action.run(
			testContext,
			(() => @doneCallbackCalled = true),
			(() =>
				@failCallbackCalled = true
				@failContext = testContext)
		)

	then:
		failCallbackCalled: should.be true
		failContext: should.be -> @testContext
		doneCallbackCalled: should.be undefined
},
{
	"given an action that receives two arguments": ->
		@argumentsToSend = [42, "test-arg"]
		recordArguments = ((x,y) => @firstArg = x; @secondArg = y)
		@action = new Witness.Action recordArguments, @argumentsToSend
		
	"when the action is run": ->
		@action.run {}, (->), (->)
		
	then:
		firstArg: should.be -> @argumentsToSend[0]
		secondArg: should.be -> @argumentsToSend[1]
}
