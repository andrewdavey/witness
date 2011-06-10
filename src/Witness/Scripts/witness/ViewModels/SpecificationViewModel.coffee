# reference "ViewModels.coffee"
# reference "ScenarioViewModel.coffee"

this.Witness.ViewModels.SpecificationViewModel = class SpecificationViewModel
	constructor: (@specification) ->
		@description = @specification.description
		@scenarios = (new Witness.ViewModels.ScenarioViewModel(scenario) for scenario in @specification.scenarios)

	run: (context, done, fail) ->
		tryAll = new Witness.TryAll @scenarios
		tryAll.run context, done, fail
