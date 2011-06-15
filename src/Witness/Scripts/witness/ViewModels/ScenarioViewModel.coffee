# reference "ViewModels.coffee"
# reference "ActionWatcher.coffee"
# reference "../../lib/knockout.js"

ActionWatcher = this.Witness.ViewModels.ActionWatcher

this.Witness.ViewModels.ScenarioViewModel = class ScenarioViewModel
	
	constructor: (@scenario) ->
		@status = ko.observable "notrun"
		@isSelected = ko.observable false
		@givenDescription = @scenario.given.description
		@givens = (new ActionWatcher action for action in @scenario.given.actions when action.description?)
		@whenDescription = @scenario.when.description
		@whens = (new ActionWatcher action for action in @scenario.when.actions when action.description?)
		@thenDescription = @scenario.then.description
		@thens = (new ActionWatcher action for action in @scenario.then.actions when action.description?)
		@errors = ko.observableArray []
		@scenario.on.run.addHandler => @status "running"
		@scenario.on.done.addHandler => @status "passed"
		@scenario.on.fail.addHandler (errors) =>
			@errors errors
			@status "failed"

	run: (context, done, fail) ->
		@scenario.run context, done, fail

	reset: ->
		@errors.removeAll()
		for watchers in [ @givens, @whens, @thens ]
			for watcher in watchers
				watch.reset()

	select: ->
		@isSelected true
		Witness.MessageBus.send "ScenarioSelected", this
		
	deselect: ->
		@isSelected false


currentSelection = null
Witness.MessageBus.addHandler "ScenarioSelected", (scenarioViewModel) ->
	currentSelection.deselect() if currentSelection?
	currentSelection = scenarioViewModel
