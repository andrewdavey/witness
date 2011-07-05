# reference "../Dsl.coffee"
# reference "../Action.coffee"
# reference "../AsyncAction.coffee"

{ Action, AsyncAction } = @Witness
{ splitCasedString } = @Witness.helpers

@Witness.Dsl::defineAction = (name, func) ->
	# An action factory is a function that captures its arguments
	# and returns a new Action that will call the original function with them.
	actionFactory = (args...) ->
		description = createActionDescription name, args
		if func.async?
			new AsyncAction func, args, description, func.async.timeout
		else
			new Action func, args, description
	if @target?
		@target[name] = actionFactory
	else
		@[name] = actionFactory

@Witness.Dsl::defineActions = (definitions) ->
	@defineAction name, func for own name, func of definitions

createActionDescription = (name, args) ->
	splitCasedString(name) + " " + args.join(", ")
