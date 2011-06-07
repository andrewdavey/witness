# reference "Witness.coffee"
# reference "Action.coffee"
# reference "StringHelpers.coffee"

{splitCasedString} = Witness.helpers;

# Dsl stores actions and assertions available for use by specifications
this.Witness.Dsl = class Dsl
	
	constructor: (@target) ->
		for own name, func of Dsl.functions
			do (func) =>
				@target[name] = ((args...) => func.apply(this, args))
	
	# Static Dsl can be extended
	@functions: {}
	@add: (objectOfFunctions) ->
		@functions[name] = func for own name, func of objectOfFunctions

Dsl.add {
	defineAction: (name, func) ->
		# An action factory is a function that captures its arguments
		# and returns a new Action that will call the original function with them.
		actionFactory = (args...) ->
			description = createActionDescription name, args
			new Witness.Action description, func, args
		@target[name] = actionFactory

	defineActions: (definitions) ->
		@target.defineAction name, func for own name, func of definitions
}




createActionDescription = (name, args) ->
	splitCasedString(name) + " " + args.join(", ")