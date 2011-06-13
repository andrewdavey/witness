# reference "../Dsl.coffee"

this.Witness.Dsl::defineAction = (name, func) ->
	# An action factory is a function that captures its arguments
	# and returns a new Action that will call the original function with them.
	actionFactory = (args...) ->
		description = createActionDescription name, args
		if func.async?
			new Witness.AsyncAction func, args, description, func.async.timeout
		else
			new Witness.Action func, args, description
	if @target?
		@target[name] = actionFactory
	else
		@[name] = actionFactory

this.Witness.Dsl::defineActions = (definitions) ->
	@defineAction name, func for own name, func of definitions


{splitCasedString} = Witness.helpers;

createActionDescription = (name, args) ->
	splitCasedString(name) + " " + args.join(", ")
