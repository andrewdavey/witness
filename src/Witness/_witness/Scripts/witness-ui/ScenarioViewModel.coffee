# reference "_namespace.coffee"
# reference "PartViewModel.coffee"

{ PartViewModel } = @witness.ui

@witness.ui.ScenarioViewModel = class ScenarioViewModel

	constructor: (@scenario) ->
		{ @path, @url } = @scenario.parentSpecification.parentFile
		@parts = (new PartViewModel part for part in [].concat @scenario.given, @scenario.when, @scenario.then)
		@errors = ko.observableArray []

		@scenario.on.failed.addHandler (errors) =>
			if jQuery.isArray errors
				for error in errors when not error.stack or error.fromAssertion
					error.stack = ""
				@errors errors
			else
				error = errors
				if not error.stack or error.fromAssertion
					error.stack = ""
				@errors [ error ]

	templateId: "scenario"
