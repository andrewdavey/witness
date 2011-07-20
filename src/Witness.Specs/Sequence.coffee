# reference "../witness/dsl/describe.coffee"
# reference "../witness/Action.coffee"
# reference "../witness/Sequence.coffee"

describe "Sequence",
{
	"given a Sequence of two actions that complete": ->
		@context = {}
		@outerContext = outerContext = this
		action0 = new witness.Action (-> outerContext.action0Called = true; outerContext.action0Context = this)
		action1 = new witness.Action (-> outerContext.action1Called = true; outerContext.action1Context = this)
		@sequence = new witness.Sequence [action0, action1]

	"when the sequence is run": ->
		@sequence.run @context, (=> @doneCallbackCalled = true), (=> @failCallbackCalled = true)

	"then the sequence completes":
		action0Called: should.be true
		action0Context: should.be -> @context
		action1Called: should.be true
		action1Context: should.be -> @context
		doneCallbackCalled: should.be true
		failCallbackCalled: should.be undefined
},
{
	"given a Sequence where the first action fails": ->
		action0 = new witness.Action (=> throw new Error "action-0 failed")
		action1 = new witness.Action (=> @action1Called = true)
		@sequence = new witness.Sequence [action0, action1]

	"when the sequence is run": ->
		@sequence.run {}, (=> @doneCallbackCalled = true), ((error) => @error = error)

	"then the sequence fails":
		action1Called: should.be undefined
		doneCallbackCalled: should.be undefined
		error: message: should.be "action-0 failed"
},
{
	"given a Sequence where the second action fails": ->
		action0 = new witness.Action (=> @action0Called = true)
		action1 = new witness.Action (=> throw new Error "action-1 failed")
		@sequence = new witness.Sequence [action0, action1]

	"when the sequence is run": ->
		@sequence.run {}, (=> @doneCallbackCalled = true), ((error) => @error = error)

	"then the sequence fails":
		action0Called: should.be true
		doneCallbackCalled: should.be undefined
		error: message: should.be "action-1 failed"
}
