# reference "../witness/dsl/describe.coffee"
# reference "../witness/Action.coffee"

describe "Action",
{
	given: ->
		@testContext = {}
		@action = new Witness.Action "action-name", (->), []
		
	when: ->
		testContext = @testContext
		@action.run(
			testContext,
			(() =>
				@doneCallbackCalled = true
				@doneContext = testContext),
			(() => @failCallbackCalled = true)
		)
	
	then:
		action: { name: should.be "action-name" }
		doneCallbackCalled: should.be true
		doneContext: should.be -> @testContext
		failCallbackCalled: should.be undefined
},
{
	given: ->
		@testContext = {}
		@action = new Witness.Action "action-name", (-> throw new Error "failed"), []
		
	when: ->
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
	given: -> # Action that has two arguments
		@argumentsToSend = [42, "test-arg"]
		recordArguments = ((x,y) => @firstArg = x; @secondArg = y)
		@action = new Witness.Action "action-name", recordArguments, @argumentsToSend
		
	when: ->
		@action.run {}, (->), (->)
		
	then:
		firstArg: should.be -> @argumentsToSend[0]
		secondArg: should.be -> @argumentsToSend[1]
}