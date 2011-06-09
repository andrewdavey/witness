# reference "../witness/dsl/describe.coffee"
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
		action0 = new Witness.Action "action-0", (=> throw new Error "action-0 failed"), []
		action1 = new Witness.Action "action-1", (=> @action1Called = true), []
		@tryAll = new Witness.TryAll [action0, action1]

	when: ->
		@tryAll.run {}, (=> @doneCallbackCalled = true), ((errors) => @errors = errors)

	then:
		action1Called: should.be true
		doneCallbackCalled: should.be undefined
		errors: [ message: should.be "action-0 failed" ]
},
{
	given: ->
		action0 = new Witness.Action "action-0", (=> @action0Called = true), []
		action1 = new Witness.Action "action-1", (=> throw new Error "action-1 failed"), []
		@tryAll = new Witness.TryAll [action0, action1]

	when: ->
		@tryAll.run {}, (=> @doneCallbackCalled = true), ((errors) => @errors = errors)

	then:
		action0Called: should.be true
		doneCallbackCalled: should.be undefined
		errors: [ message: should.be "action-1 failed" ]
},
{
	given: ->
		action0 = new Witness.Action "action-0", (=> throw new Error "action-0 failed"), []
		action1 = new Witness.Action "action-1", (=> throw new Error "action-1 failed"), []
		@tryAll = new Witness.TryAll [action0, action1]

	when: ->
		@tryAll.run {}, (=> @doneCallbackCalled = true), ((errors) => @errors = errors)

	then:
		doneCallbackCalled: should.be undefined
		errors: [
			{ message: should.be "action-0 failed" },
			{ message: should.be "action-1 failed" }
		]
}