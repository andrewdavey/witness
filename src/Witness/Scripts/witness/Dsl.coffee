# reference "Witness.coffee"
# reference "Action.coffee"
# reference "StringHelpers.coffee"

this.Witness.Dsl = class Dsl
	
	# @target will usually be the global window object
	constructor: (@target) ->

	# Add each function in the DSL to the target object
	activate: ->
		for own name, func of Object.getPrototypeOf(this)
			continue if name == "constructor"
			do (func) =>
				# Always call DSL functions in the context of the DSL.
				@target[name] = ((args...) => func.apply(this, args))

	# See ~/scripts/witness/dsl/* for definitions of DSL functions