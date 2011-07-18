# reference "_namespace.coffee"

@Witness.ui.ScenarioViewModel = class ScenarioViewModel

	constructor: (@scenario) ->
		@givenDescription = @scenario.given.description
		@whenDescription = @scenario.when.description
		@thenDescription = @scenario.then.description
		@errors = ko.observableArray []

		@scenario.on.failed.addHandler (errors) =>
			@errors errors

	templateId: "scenario"

