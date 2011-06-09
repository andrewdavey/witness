should.haveStatus = predicateActionBuilder
	test: (actual, expected) -> actual.status() == expected
	description: (fullName, expected) -> "View model status should be \"#{expected}\""
	error: (fullName, actual, expected) -> "Expected view model status to be \"#{expected}\" but was \"#{actual}\""
	
describe "ActionWatcher with Action",
{
	given: ->
		@action = new Witness.Action "action-name", (->), []
		@watcher = new Witness.ViewModels.ActionWatcher @action

	then:
		watcher:
			this: should.haveStatus "notrun"
			name: should.be "action-name"
},
{
	given: ->
		@action = new Witness.Action "action-name", (-> throw new Error "action failed"), []
		@watcher = new Witness.ViewModels.ActionWatcher @action

	when: ->
		@action.run {}, (->), (->)

	then:
		watcher: should.haveStatus "failed"
},
{
	given: ->
		@action = new Witness.Action "action-name", (->), []
		@watcher = new Witness.ViewModels.ActionWatcher @action

	when: ->
		@action.run {}, (->), (->)

	then:
		watcher: should.haveStatus "passed"
},
{
	given: ->
		@action = new Witness.Action "action-name", (->), []
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
		@action = new Witness.AsyncAction "action-name", (-> @done()), []
		@watcher = new Witness.ViewModels.ActionWatcher @action

	then:
		watcher:
			this: should.haveStatus "notrun"
			name: should.be "action-name"
},
{
	given: ->
		@action = new Witness.AsyncAction "action-name", (-> @done()), []
		@watcher = new Witness.ViewModels.ActionWatcher @action

	when: ->
		@action.run {}, (->), (->)

	then:
		watcher: should.haveStatus "passed"
},
{
	given: ->
		@action = new Witness.AsyncAction "action-name", (-> @fail()), []
		@watcher = new Witness.ViewModels.ActionWatcher @action

	when: ->
		@action.run {}, (->), (->)

	then:
		watcher: should.haveStatus "failed"
},
{
	given: ->
		@action = new Witness.AsyncAction "action-name", (-> @done()), []
		@watcher = new Witness.ViewModels.ActionWatcher @action
		@action.run {}, (->), (->)

	when: ->
		@watcher.reset()

	then:
		watcher: should.haveStatus "notrun"
}