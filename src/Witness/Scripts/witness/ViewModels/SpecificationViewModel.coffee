# reference "ViewModels.coffee"
# reference "Helpers.coffee"
# reference "ScenarioViewModel.coffee"

this.Witness.ViewModels.SpecificationViewModel = class SpecificationViewModel
	constructor: (@specification) ->
		@description = @specification.description
		@scenarios = (Witness.ViewModels.createScenarioViewModel scenario for scenario in @specification.scenarios)
		@isOpen = ko.observable false
		@status = ko.observable "notrun"

		@specification.on.running.addHandler =>
			@status "running"
		@specification.on.passed.addHandler =>
			@status "passed"
		@specification.on.failed.addHandler =>
			@status "failed"

	run: ->
		@specification.run {}, (->), (->)

	toggleOpen: ->
		@isOpen(not @isOpen())

	scenarioTemplate: (item) ->
		if item instanceof Witness.ViewModels.OuterScenarioViewModel
			"outer-scenario"
		else
			"scenario"

	reset: ->
		scenario.reset() for scenario in @scenarios
