# reference "../witness/dsl/describe.coffee"
# reference "../witness/Action.coffee"
# reference "../witness/Sequence.coffee"

describe "Sequence",
{
	given: ->
		@context = {}
		@outerContext = outerContext = this
		action0 = new Witness.Action (-> outerContext.action0Called = true; outerContext.action0Context = this)
		action1 = new Witness.Action (-> outerContext.action1Called = true; outerContext.action1Context = this)
		@sequence = new Witness.Sequence [action0, action1]

	when: ->
		@sequence.run @context, (=> @doneCallbackCalled = true), (=> @failCallbackCalled = true)

	then:
		action0Called: should.be true
		action0Context: should.be -> @context
		action1Called: should.be true
		action1Context: should.be -> @context
		doneCallbackCalled: should.be true
		failCallbackCalled: should.be undefined
},
{
	given: ->
		action0 = new Witness.Action (=> throw new Error "action-0 failed")
		action1 = new Witness.Action (=> @action1Called = true)
		@sequence = new Witness.Sequence [action0, action1]

	when: ->
		@sequence.run {}, (=> @doneCallbackCalled = true), ((error) => @error = error)

	then:
		action1Called: should.be undefined
		doneCallbackCalled: should.be undefined
		error: message: should.be "action-0 failed"
}
