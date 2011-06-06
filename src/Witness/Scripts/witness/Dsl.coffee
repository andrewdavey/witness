# reference "Witness.coffee"
# reference "Action.coffee"
# reference "StringHelpers.coffee"

{splitCasedString} = Witness.helpers;

# Dsl stores actions and assertions available for use by specifications
# It can be extended using the define* functions.
this.Witness.Dsl = class Dsl
	
	defineAction: (name, func) ->
		# An action factory is a function that captures its arguments
		# and returns a new Action that will call the original function with them.
		actionFactory = (args...) ->
			description = createActionDescription name, args
			new Witness.Action description, func, args
		@[name] = actionFactory

	defineActions: (definitions) ->
		@defineAction name, func for own name, func of definitions


createActionDescription = (name, args) ->
	splitCasedString(name) + " " + args.join(", ")