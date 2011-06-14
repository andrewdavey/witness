# reference "ViewModels.coffee"
# reference "../../lib/knockout.js"

this.Witness.ViewModels.OuterScenarioViewModel = class OuterScenarioViewModel

	constructor: (@outerScenario) ->
		@innerScenarios = @outerScenario.innerScenarios
		@status = ko.observable "notrun"
		@isOpen = ko.observable true
		@outerScenario.on.run.addHandler => @status "running"
		@outerScenario.on.done.addHandler => @status "passed"
		@outerScenario.on.fail.addHandler (error) => @status "failed"

	run: (context, done, fail) ->
		@outerScenario.run {}, done, fail

	scenarioTemplate: (item) ->
		if item instanceof Witness.ViewModels.OuterScenarioViewModel
			"outer-scenario"
		else
			"scenario"


