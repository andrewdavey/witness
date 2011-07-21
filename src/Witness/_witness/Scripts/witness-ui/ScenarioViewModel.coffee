# reference "_namespace.coffee"
# reference "ActionViewModel.coffee"

{ ActionViewModel } = @witness.ui

@witness.ui.ScenarioViewModel = class ScenarioViewModel

	constructor: (@scenario) ->
		{ @path, @url } = @scenario.parentSpecification.parentFile
		@givenDescription = @scenario.given.description
		@givenActions = actionsViewModel @scenario.given.actions
		@whenDescription = @scenario.when.description
		@whenActions = actionsViewModel @scenario.when.actions
		@thenDescription = @scenario.then.description
		@thenActions = actionsViewModel @scenario.then.actions
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

actionsViewModel = (actions) ->
	(new ActionViewModel action for action in actions)
