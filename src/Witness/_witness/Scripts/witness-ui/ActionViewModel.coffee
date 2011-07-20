# reference "../lib/knockout.js"
# reference "_namespace.coffee"

# An action will raise events when run.
# The ActionViewModel handles these and maintains an observable status.
# This means the action can remain stateless, while the watcher can be bound the UI.

@witness.ui.ActionViewModel = class ActionViewModel

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
