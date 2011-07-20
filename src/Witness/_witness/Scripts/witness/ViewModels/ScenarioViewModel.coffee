# reference "ViewModels.coffee"
# reference "ActionWatcher.coffee"
# reference "../MessageBus.coffee"
# reference "../helpers.coffee"
# reference "../../lib/knockout.js"

{ messageBus } = @witness
{ flattenArray } = @witness.helpers
{ ActionWatcher } = @witness.ViewModels

@witness.ViewModels.ScenarioViewModel = class ScenarioViewModel
	
	constructor: (@scenario) ->
		@status = ko.observable "notrun"
		@isSelected = ko.observable false
		@errors = ko.observableArray []

		@givenDescription = @scenario.given.description
		@givens = for action in @scenario.given.actions
			new ActionWatcher action
		@givensVisible = ko.observable (@givenDescription.length == 0)

		@whenDescription = @scenario.when.description
		@whens = for action in @scenario.when.actions
			new ActionWatcher action
		@whensVisible = ko.observable (@whenDescription.length == 0)
		
		@thenDescription = @scenario.then.description
		@thens = for action in @scenario.then.actions
			new ActionWatcher action
		
		# Handle events raised by the scenario and update the view model state.
		@scenario.on.running.addHandler =>
			@reset()
			@select()
			@status "running"
		@scenario.on.passed.addHandler =>
			@status "passed"
		@scenario.on.failed.addHandler (errors) =>
			@errors flattenArray errors
			@status "failed"

	run: ->
		@scenario.run {}, (->), (->)

	reset: ->
		@status "notrun"
		@errors.removeAll()
		for watchers in [ @givens, @whens, @thens ]
			for watcher in watchers
				watcher.reset()

	select: ->
		@isSelected true
		messageBus.send "ScenarioSelected", this
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
messageBus.addHandler "ScenarioSelected", (scenarioViewModel) ->
	return if scenarioViewModel is currentSelection
	currentSelection.deselect() if currentSelection?
	currentSelection = scenarioViewModel
