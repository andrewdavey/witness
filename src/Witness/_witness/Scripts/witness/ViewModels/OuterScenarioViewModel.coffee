# reference "ViewModels.coffee"
# reference "Helpers.coffee"
# reference "../../lib/knockout.js"
# reference "ActionWatcher.coffee"
# reference "Helpers.coffee"
# reference "OuterScenarioViewModel.coffee"

{ ActionWatcher, OuterScenarioViewModel, createScenarioViewModel } = @witness.ViewModels

@witness.ViewModels.OuterScenarioViewModel = class OuterScenarioViewModel

	constructor: (@outerScenario) ->
		@givenDescription = @outerScenario.given.description
		@givens = (new ActionWatcher action for action in @outerScenario.given.actions)
		@givensVisible = ko.observable (@givenDescription.length == 0)
		@innerScenarios = (createScenarioViewModel scenario for scenario in @outerScenario.innerScenarios)
		@status = ko.observable "notrun"
		@isOpen = ko.observable true
		@outerScenario.on.running.addHandler => @status "running"
		@outerScenario.on.passed.addHandler => @status "passed"
		@outerScenario.on.failed.addHandler (error) => @status "failed"

	run: ->
		@outerScenario.run {}, (->), (->)

	reset: ->
		scenario.reset() for scenario in @innerScenarios

	toggleGivens: ->
		@givensVisible not @givensVisible()

	scenarioTemplate: (item) ->
		if item instanceof OuterScenarioViewModel
			"outer-scenario"
		else
			"scenario"


