# reference "ViewModels.coffee"
# reference "Helpers.coffee"
# reference "ScenarioViewModel.coffee"

this.Witness.ViewModels.SpecificationViewModel = class SpecificationViewModel
	constructor: (@specification) ->
		@description = @specification.description
		@scenarios = (Witness.ViewModels.createScenarioViewModel scenario for scenario in @specification.scenarios)
		@isOpen = ko.observable true

	run: (context, done, fail) ->
		tryAll = new Witness.TryAll @scenarios
		tryAll.run context, done, (error) ->
			console.log error
			fail error

	toggleOpen: ->
		@isOpen(not @isOpen())

	scenarioTemplate: (item) ->
		if item instanceof Witness.ViewModels.OuterScenarioViewModel
			"outer-scenario"
		else
			"scenario"


