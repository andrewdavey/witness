# reference "../witness/describe.coffee"
# reference "../witness/Action.coffee"
# reference "../witness/Sequence.coffee"

describe "Sequence",
{
	given: ->
		@context = {};
		@outerContext = outerContext = this
		action0 = new Witness.Action "action-0", (-> outerContext.action0Called = true; outerContext.action0Context = this), []
		action1 = new Witness.Action "action-1", (-> outerContext.action1Called = true; outerContext.action1Context = this), []
		@sequence = new Witness.Sequence [action0, action1]

	when: ->
		@sequence.run @context, (=> @doneCallbackCalled = true), (=> @failCallbackCalled = true)

	then: [
		-> @action0Called == true
		-> @action0Context == @context
		-> @action1Called == true
		-> @action1Context == @context
		-> @doneCallbackCalled?
		-> not @failCallbackCalled
	]
},
{
	given: ->
		action0 = new Witness.Action "action-0", (=> throw new Error "action-0 failed"), []
		action1 = new Witness.Action "action-1", (=> @action1Called = true), []
		@sequence = new Witness.Sequence [action0, action1]

	when: ->
		@sequence.run {}, (=> @doneCallbackCalled = true), ((error) => @error = error)

	then: [
		-> not @action1Called
		-> not @doneCallbackCalled
		-> @error.message == "action-0 failed"
	]
}