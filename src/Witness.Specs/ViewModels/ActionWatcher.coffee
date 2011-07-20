describe "ActionWatcher with Action",
{
	"given an ActionWatcher of an Action with a description": ->
		@action = new witness.Action (->), [], "description"
		@watcher = new witness.ViewModels.ActionWatcher @action

	then:
		watcher:
			status: should.be "notrun"
			description: should.be "description"
},
{
	"given an ActionWatcher where the action throws an error": ->
		@action = new witness.Action (-> throw new Error "action failed")
		@watcher = new witness.ViewModels.ActionWatcher @action

	"when it is run": ->
		@action.run {}, (->), (->)

	then:
		watcher: status: should.be "failed"
},
{
	"given an ActionWatcher where the action passes": ->
		@action = new witness.Action (->)
		@watcher = new witness.ViewModels.ActionWatcher @action

	"when it is run": ->
		@action.run {}, (->), (->)

	then:
		watcher: status: should.be "passed"
},
{
	"given an ActionWatcher that has been run": ->
		@action = new witness.Action (->)
		@watcher = new witness.ViewModels.ActionWatcher @action
		@action.run {}, (->), (->)

	"when it is reset": ->
		@watcher.reset()

	then:
		watcher: status: should.be "notrun"
}

describe "ActionWatcher with AsyncAction",
{
	"given an ActionWatcher with an AsyncAction that calls done": ->
		@action = new witness.AsyncAction (-> @done()), [], "action-name"
		@watcher = new witness.ViewModels.ActionWatcher @action

	then:
		watcher:
			status: should.be "notrun"
			description: should.be "action-name"
},
{
	"given an ActionWatcher with an AsyncAction that calls done": ->
		@action = new witness.AsyncAction (-> @done())
		@watcher = new witness.ViewModels.ActionWatcher @action

	"when it is run": ->
		@action.run {}, (->), (->)

	then:
		watcher: status: should.be "passed"
},
{
	"given an ActionWatcher with an AsyncAction that fails": ->
		@action = new witness.AsyncAction (-> @fail())
		@watcher = new witness.ViewModels.ActionWatcher @action

	"when is is run": ->
		@action.run {}, (->), (->)

	then:
		watcher: status: should.be "failed"
},
{
	"given an ActionWatcher with an AsyncAction and has been run": ->
		@action = new witness.AsyncAction (-> @done())
		@watcher = new witness.ViewModels.ActionWatcher @action
		@action.run {}, (->), (->)

	"when it is reset": ->
		@watcher.reset()

	then:
		watcher: status: should.be "notrun"
}
