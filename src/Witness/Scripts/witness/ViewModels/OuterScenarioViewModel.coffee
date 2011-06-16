# reference "ViewModels.coffee"
# reference "Helpers.coffee"
# reference "../../lib/knockout.js"

this.Witness.ViewModels.OuterScenarioViewModel = class OuterScenarioViewModel

	constructor: (@outerScenario) ->
		@givenDescription = @outerScenario.given.description
		@givens = (new Witness.ViewModels.ActionWatcher action for action in @outerScenario.given.actions)
		@innerScenarios = (Witness.ViewModels.createScenarioViewModel scenario for scenario in @outerScenario.innerScenarios)
		@status = ko.observable "notrun"
		@isOpen = ko.observable true
		@outerScenario.on.run.addHandler => @status "running"
		@outerScenario.on.done.addHandler => @status "passed"
		@outerScenario.on.fail.addHandler (error) => @status "failed"

	run: (context, done, fail) ->
		@outerScenario.run {}, done, fail

	reset: ->
		scenario.reset() for scenario in @innerScenarios

	scenarioTemplate: (item) ->
		if item instanceof Witness.ViewModels.OuterScenarioViewModel
			"outer-scenario"
		else
			"scenario"


