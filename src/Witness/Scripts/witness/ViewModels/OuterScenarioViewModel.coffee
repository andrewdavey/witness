# reference "ViewModels.coffee"
# reference "../../lib/knockout.js"

this.Witness.ViewModels.OuterScenarioViewModel = class OuterScenarioViewModel

	constructor: (@outerScenario) ->
		@status = ko.observable "notrun"
