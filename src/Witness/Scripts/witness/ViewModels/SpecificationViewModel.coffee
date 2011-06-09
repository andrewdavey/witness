# reference "ViewModels.coffee"

this.Witness.ViewModels.SpecificationViewModel = class SpecificationViewModel
	constructor: (@specification) ->
		@description = @specification.description
		@scenarios = (new Witness.ViewModels.ScenarioViewModel(scenario) for scenario in @specification.scenarios)

