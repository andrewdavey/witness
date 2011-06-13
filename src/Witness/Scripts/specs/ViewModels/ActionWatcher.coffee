should.haveStatus = predicateActionBuilder
	test: (actual, expected) -> actual.status() == expected
	description: (fullName, expected) -> "View model status should be \"#{expected}\""
	error: (fullName, actual, expected) -> "Expected view model status to be \"#{expected}\" but was \"#{actual}\""
	
describe "ActionWatcher with Action",
{
	"given ActionWatcher of an Action with a description": ->
		@action = new Witness.Action (->), [], "description"
		@watcher = new Witness.ViewModels.ActionWatcher @action

	then:
		watcher:
			this: should.haveStatus "notrun"
			description: should.be "description"
},
{
	given: ->
		@action = new Witness.Action (-> throw new Error "action failed")
		@watcher = new Witness.ViewModels.ActionWatcher @action

	when: ->
		@action.run {}, (->), (->)

	then:
		watcher: should.haveStatus "failed"
},
{
	given: ->
		@action = new Witness.Action (->)
		@watcher = new Witness.ViewModels.ActionWatcher @action

	when: ->
		@action.run {}, (->), (->)

	then:
		watcher: should.haveStatus "passed"
},
{
	given: ->
		@action = new Witness.Action (->)
		@watcher = new Witness.ViewModels.ActionWatcher @action
		@action.run {}, (->), (->)

	when: ->
		@watcher.reset()

	then:
		watcher: should.haveStatus "notrun"
}

describe "ActionWatcher with AsyncAction",
{
	given: ->
		@action = new Witness.AsyncAction (-> @done()), [], "action-name"
		@watcher = new Witness.ViewModels.ActionWatcher @action

	then:
		watcher:
			this: should.haveStatus "notrun"
			description: should.be "action-name"
},
{
	given: ->
		@action = new Witness.AsyncAction (-> @done())
		@watcher = new Witness.ViewModels.ActionWatcher @action

	when: ->
		@action.run {}, (->), (->)

	then:
		watcher: should.haveStatus "passed"
},
{
	given: ->
		@action = new Witness.AsyncAction (-> @fail())
		@watcher = new Witness.ViewModels.ActionWatcher @action

	when: ->
		@action.run {}, (->), (->)

	then:
		watcher: should.haveStatus "failed"
},
{
	given: ->
		@action = new Witness.AsyncAction (-> @done())
		@watcher = new Witness.ViewModels.ActionWatcher @action
		@action.run {}, (->), (->)

	when: ->
		@watcher.reset()

	then:
		watcher: should.haveStatus "notrun"
}
