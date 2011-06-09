# reference "ViewModels.coffee"
# reference "ActionWatcher.coffee"
# reference "../../lib/knockout.js"

ActionWatcher = this.Witness.ViewModels.ActionWatcher

this.Witness.ViewModels.ScenarioViewModel = class ScenarioViewModel
	
	constructor: (@scenario) ->
		@status = ko.observable "notrun"
		@givens = (new ActionWatcher action for action in @scenario.givens)
		@whens = (new ActionWatcher action for action in @scenario.whens)
		@thens = (new ActionWatcher action for action in @scenario.thens)

	run: (context, done, fail) ->
		@status "running"
		@scenario.run {},
			() =>
				@status "passed"
				done()
			(errors) =>
				@status "failed"
				fail errors

	reset: ->
		for watchers in [ @givens, @whens, @thens ]
			for watcher in watchers
				watch.reset()