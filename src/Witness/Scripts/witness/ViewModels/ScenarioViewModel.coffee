# reference "ViewModels.coffee"
# reference "ActionWatcher.coffee"
# reference "../../lib/knockout.js"

ActionWatcher = this.Witness.ViewModels.ActionWatcher

this.Witness.ViewModels.ScenarioViewModel = class ScenarioViewModel
	
	constructor: (@scenario) ->
		@status = ko.observable "notrun"
		@givenDescription = @scenario.given.description
		@givens = (new ActionWatcher action for action in @scenario.given.actions when action.description?)
		@whenDescription = @scenario.when.description
		@whens = (new ActionWatcher action for action in @scenario.when.actions when action.description?)
		@thenDescription = @scenario.then.description
		@thens = (new ActionWatcher action for action in @scenario.then.actions when action.description?)
		@errors = ko.observableArray []

	run: (context, done, fail) ->
		@status "running"
		@scenario.run {},
			() =>
				@status "passed"
				done()
			(errors) =>
				@status "failed"
				@errors errors
				fail errors

	reset: ->
		@errors.removeAll()
		for watchers in [ @givens, @whens, @thens ]
			for watcher in watchers
				watch.reset()
