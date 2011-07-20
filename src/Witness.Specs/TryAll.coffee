# reference "../witness/dsl/describe.coffee"
# reference "../witness/Action.coffee"
# reference "../witness/TryAll.coffee"

describe "TryAll",
{
	"given a TryAll action where both actions complete": ->
		@context = {}
		@outerContext = outerContext = this
		action0 = new witness.Action (-> outerContext.action0Called = true; outerContext.action0Context = this)
		action1 = new witness.Action (-> outerContext.action1Called = true; outerContext.action1Context = this)
		@tryAll = new witness.TryAll [action0, action1]

	"when the action is run": async ->
		@tryAll.run @context,
			(=> @doneCallbackCalled = true; @done())
			(=> @failCallbackCalled = true; @done())

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
		action0 = new witness.Action (=> throw new Error "action-0 failed")
		action1 = new witness.Action (=> @action1Called = true)
		@tryAll = new witness.TryAll [action0, action1]

	"when the action is run": async ->
		@tryAll.run {},
			(=> @doneCallbackCalled = true; @done())
			((errors) => @errors = errors; @done())

	then:
		action1Called: should.be true
		doneCallbackCalled: should.be undefined
		errors: arrayShouldBe [
			message: should.be "action-0 failed"
		]
},
{
	"given a TryAll where the second action fails": ->
		action0 = new witness.Action (=> @action0Called = true)
		action1 = new witness.Action (=> throw new Error "action-1 failed")
		@tryAll = new witness.TryAll [action0, action1]

	"when the action is run": async ->
		@tryAll.run {},
			(=> @doneCallbackCalled = true; @done())
			((errors) => @errors = errors; @done())

	then:
		action0Called: should.be true
		doneCallbackCalled: should.be undefined
		errors: arrayShouldBe [
			message: should.be "action-1 failed"
		]
},
{
	"given a TryAll where both actions fail": ->
		action0 = new witness.Action (=> throw new Error "action-0 failed")
		action1 = new witness.Action (=> throw new Error "action-1 failed")
		@tryAll = new witness.TryAll [action0, action1]

	"when the action is run": async ->
		@tryAll.run {},
			(=> @doneCallbackCalled = true; @done())
			((errors) => @errors = errors; @done())

	then:
		doneCallbackCalled: should.be undefined
		errors: arrayShouldBe [
			{ message: should.be "action-0 failed" }
			{ message: should.be "action-1 failed" }
		]
},
{
	"given a TryAll with no actions": ->
		@tryAll = new witness.TryAll []

	"when the action is run": async ->
		@tryAll.run {},
			(=> @doneCallbackCalled = true; @done())
			(=> @done())

	then:
		doneCallbackCalled: should.be true
}
