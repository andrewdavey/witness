# reference "ViewModels.coffee"
# reference "ActionWatcher.coffee"
# reference "../../lib/knockout.js"

ActionWatcher = this.Witness.ViewModels.ActionWatcher
flattenArray = this.Witness.helpers.flattenArray

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
			@errors flattenArray errors
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
		if @scenario.iframe?
			@scenario.iframe.show()

	deselect: ->
		@isSelected false
		if @scenario.iframe?
			@scenario.iframe.hide()

currentSelection = null
Witness.MessageBus.addHandler "ScenarioSelected", (scenarioViewModel) ->
	currentSelection.deselect() if currentSelection?
	currentSelection = scenarioViewModel
