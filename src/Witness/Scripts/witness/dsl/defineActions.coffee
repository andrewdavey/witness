# reference "../Dsl.coffee"

this.Witness.Dsl::defineAction = (name, func) ->
	# An action factory is a function that captures its arguments
	# and returns a new Action that will call the original function with them.
	actionFactory = (args...) ->
		description = createActionDescription name, args
		new Witness.Action description, func, args
	@target[name] = actionFactory

this.Witness.Dsl::defineActions = (definitions) ->
	@target.defineAction name, func for own name, func of definitions


{splitCasedString} = Witness.helpers;

createActionDescription = (name, args) ->
	splitCasedString(name) + " " + args.join(", ")