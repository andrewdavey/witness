# reference "../../lib/knockout.js"
# reference "ViewModels.coffee"

# An action will raise events when run.
# A watcher object handles these and maintains an observable status.
# This means the action can remain stateless, while the watcher can be bound the UI.


@witness.ViewModels.ActionWatcher = class ActionWatcher
	constructor: (@action) ->
		@description = @action.description
		@errors = ko.observableArray []
		@status = ko.observable "notrun"
		@action.on.running.addHandler  =>
			@reset()
			@status "running"
		@action.on.passed.addHandler =>
			@status "passed"
		@action.on.failed.addHandler (error) =>
			@status "failed"
			@errors.push error

	reset: ->
		@status "notrun"
		@errors.removeAll()
