# reference "_namespace.coffee"

@Witness.ui.ScenarioViewModel = class ScenarioViewModel

	constructor: (@scenario) ->
		@givenDescription = @scenario.given.description
		@whenDescription = @scenario.when.description
		@thenDescription = @scenario.then.description

	templateId: "scenario"

	run: ->
		@scenario.run {}, (->), (->)
