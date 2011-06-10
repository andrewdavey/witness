# reference "../../lib/knockout.js"
# reference "ViewModels.coffee"

# An action will raise events when run.
# A watcher object handles these and maintains an observable status.
# This means the action can remain stateless, while the watcher can be bound the UI.

this.Witness.ViewModels.ActionWatcher = class ActionWatcher
	constructor: (@action) ->
		@name = @action.name
		@errors = ko.observableArray []
		@status = ko.observable "notrun"
		@action.on.run.addHandler  => @status "running"
		@action.on.done.addHandler => @status "passed"
		@action.on.fail.addHandler (error) =>
			@status "failed"
			@errors.push error

	reset: ->
		@status "notrun"
