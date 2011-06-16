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
		@givens = (new ActionWatcher action for action in @scenario.given.actions)
		@givensVisible = ko.observable (@givenDescription.length == 0)
		@whenDescription = @scenario.when.description
		@whens = (new ActionWatcher action for action in @scenario.when.actions)
		@whensVisible = ko.observable (@whenDescription.length == 0)
		@thenDescription = @scenario.then.description
		@thens = (new ActionWatcher action for action in @scenario.then.actions)
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
		Witness.messageBus.send "ScenarioSelected", this
		if @scenario.iframe?
			@scenario.iframe.show()

	deselect: ->
		@isSelected false
		if @scenario.iframe?
			@scenario.iframe.hide()

	toggleGivens: ->
		@givensVisible not @givensVisible()

	toggleWhens: ->
		@whensVisible not @whensVisible()


currentSelection = null
Witness.messageBus.addHandler "ScenarioSelected", (scenarioViewModel) ->
	return if scenarioViewModel is currentSelection
	currentSelection.deselect() if currentSelection?
	currentSelection = scenarioViewModel
