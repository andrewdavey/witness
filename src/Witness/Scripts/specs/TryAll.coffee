# reference "../witness/describe.coffee"
# reference "../witness/Action.coffee"
# reference "../witness/TryAll.coffee"

describe "TryAll",
{
	given: ->
		@context = {};
		@outerContext = outerContext = this
		action0 = new Witness.Action "action-0", (-> outerContext.action0Called = true; outerContext.action0Context = this), []
		action1 = new Witness.Action "action-1", (-> outerContext.action1Called = true; outerContext.action1Context = this), []
		@tryAll = new Witness.TryAll [action0, action1]

	when: ->
		@tryAll.run @context, (=> @doneCallbackCalled = true), (=> @failCallbackCalled = true)

	then: [
		-> @action0Called
		-> @action0Context == @context
		-> @action1Called
		-> @action1Context == @context
		-> @doneCallbackCalled
		-> not @failCallbackCalled
	]
},
{
	given: ->
		action0 = new Witness.Action "action-0", (=> throw new Error "action-0 failed"), []
		action1 = new Witness.Action "action-1", (=> @action1Called = true), []
		@tryAll = new Witness.TryAll [action0, action1]

	when: ->
		@tryAll.run {}, (=> @doneCallbackCalled = true), ((error) => @error = error)

	then: [
		-> @action1Called
		-> not @doneCallbackCalled
		-> @error instanceof Array
		-> @error[0].message == "action-0 failed"
	]
},
{
	given: ->
		action0 = new Witness.Action "action-0", (=> @action0Called = true), []
		action1 = new Witness.Action "action-1", (=> throw new Error "action-1 failed"), []
		@tryAll = new Witness.TryAll [action0, action1]

	when: ->
		@tryAll.run {}, (=> @doneCallbackCalled = true), ((errors) => @errors = errors)

	then: [
		-> @action0Called
		-> not @doneCallbackCalled
		-> @errors instanceof Array
		-> @errors[0].message == "action-1 failed"
	]
},
{
	given: ->
		action0 = new Witness.Action "action-0", (=> throw new Error "action-0 failed"), []
		action1 = new Witness.Action "action-1", (=> throw new Error "action-1 failed"), []
		@tryAll = new Witness.TryAll [action0, action1]

	when: ->
		@tryAll.run {}, (=> @doneCallbackCalled = true), ((errors) => @errors = errors)

	then: [
		-> not @doneCallbackCalled
		-> @errors instanceof Array
		-> @errors[0].message == "action-0 failed"
		-> @errors[1].message == "action-1 failed"
	]
}