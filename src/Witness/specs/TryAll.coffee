# reference "../witness/dsl/describe.coffee"
# reference "../witness/Action.coffee"
# reference "../witness/TryAll.coffee"

describe "TryAll",
{
	"given a TryAll action where both actions complete": ->
		@context = {};
		@outerContext = outerContext = this
		action0 = new Witness.Action (-> outerContext.action0Called = true; outerContext.action0Context = this)
		action1 = new Witness.Action (-> outerContext.action1Called = true; outerContext.action1Context = this)
		@tryAll = new Witness.TryAll [action0, action1]

	"when the action is run": ->
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
	"given a TryAll action where the first action fails": ->
		action0 = new Witness.Action (=> throw new Error "action-0 failed")
		action1 = new Witness.Action (=> @action1Called = true)
		@tryAll = new Witness.TryAll [action0, action1]

	"when the action is run": ->
		@tryAll.run {}, (=> @doneCallbackCalled = true), ((errors) => @errors = errors)

	then:
		action1Called: should.be true
		doneCallbackCalled: should.be undefined
		errors: [ message: should.be "action-0 failed" ]
},
{
	"given a TryAll where the second action fails": ->
		action0 = new Witness.Action (=> @action0Called = true)
		action1 = new Witness.Action (=> throw new Error "action-1 failed")
		@tryAll = new Witness.TryAll [action0, action1]

	"when the action is run": ->
		@tryAll.run {}, (=> @doneCallbackCalled = true), ((errors) => @errors = errors)

	then:
		action0Called: should.be true
		doneCallbackCalled: should.be undefined
		errors: [ message: should.be "action-1 failed" ]
},
{
	"given a TryAll where both actions fail": ->
		action0 = new Witness.Action (=> throw new Error "action-0 failed")
		action1 = new Witness.Action (=> throw new Error "action-1 failed")
		@tryAll = new Witness.TryAll [action0, action1]

	"when the action is run": ->
		@tryAll.run {}, (=> @doneCallbackCalled = true), ((errors) => @errors = errors)

	then:
		doneCallbackCalled: should.be undefined
		errors: [
			{ message: should.be "action-0 failed" },
			{ message: should.be "action-1 failed" }
		]
},
{
	"given a TryAll with no actions": ->
		@tryAll = new Witness.TryAll []
	"when the action is run": ->
		@tryAll.run {}, (=>@doneCallbackCalled = true), (->)
	then:
		doneCallbackCalled: should.be true
}
