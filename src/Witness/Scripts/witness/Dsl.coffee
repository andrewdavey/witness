# reference "Witness.coffee"

@Witness.Dsl = class Dsl
	
	# @target will usually be the global window object
	constructor: (@target) ->

	# Add each function in the DSL to the target object
	activate: ->
		@target.dsl = this
		for own name, value of Object.getPrototypeOf(this)
			continue if name in [ "constructor", "activate" ]
			if typeof value == "function"
				do (value) =>
					# Always call DSL functions in the context of the DSL.
					@target[name] = ((args...) => value.apply(this, args))
			else
				@target[name] = value


	# See ~/scripts/witness/dsl/* for definitions of DSL functions
